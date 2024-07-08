

/datum/market/auction
	name = "Auction"
	shipping = list(
		SHIPPING_METHOD_LTSRBT = 40,
		SHIPPING_METHOD_LAUNCH = 10,
		SHIPPING_METHOD_TELEPORT= 75,
	)
	/// The order-specific list of the items being auctioned. Key 0 is the current item being auctioned, and after that are the items in the queue.
	var/list/datum/auction_queue = list()

/datum/market/auction/purchase(identifier, category, method, obj/item/market_uplink/uplink, user)
	. = ..()
	if(!.)
		return
	var/datum/market_item/item = available_items[category][identifier]
	SSblackmarket.auction_weights -= item
	to_chat(world, "successfully removed [item] from weights!")


/datum/market/auction/add_item(datum/market_item/item)
	auction_queue += item //todo: is this sane? Make sure we're always adding from the end of the list.
	to_chat(world, "Added [item] to the auction queue. Auction queue now contains [length(auction_queue)]")
	return ..()

/obj/item/market_uplink/auction
	name = "\improper Auction Uplink"
	desc = "An illegal uplink."
	icon = 'icons/obj/devices/blackmarket.dmi'
	icon_state = "uplink"
	//The original black market uplink
	accessible_markets = list(/datum/market/auction)
	custom_premium_price = PAYCHECK_CREW * 2.5

/obj/item/market_uplink/auction/ui_interact(mob/user, datum/tgui/ui)
	if(!viewing_category)
		update_viewing_category()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BlackMarketAuction", name)
		ui.open()
	if(!SSblackmarket.auction_running)
		SSblackmarket.auction_running = TRUE
		SSblackmarket.handle_auctions()
		for(var/datum/auctioneer/auction_options in SSblackmarket.auction_bids)
			if(auction_options.bidder == user)
				return
		// We don't exist as an auctioneer yet, roll out
		var/datum/auctioneer = new(user, 0)
		SSblackmarket.auction_bids += auctioneer

	var/datum/market/auction/prime_auction = SSblackmarket.markets[/datum/market/auction]
	for(var/i in prime_auction.auction_queue)
		to_chat(world, "Queue contains [prime_auction.auction_queue[i]]")

/obj/item/market_uplink/auction/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/card/id/id_card
	if(isliving(user))
		var/mob/living/livin = user
		id_card = livin.get_idcard()
	if(id_card?.registered_account)
		current_user = id_card.registered_account
	else
		current_user = null
	if(current_user)
		data["money"] = current_user.account_balance

	var/datum/market/auction/prime_auction = SSblackmarket.markets[/datum/market/auction]
	var/datum/market_item/current_item
	if(length(prime_auction))
		current_item = prime_auction[0]

	var/highest_bid = 0
	var/highest_bidder = "none"
	for(var/datum/auctioneer/auctioneer in SSblackmarket.auction_bids)
		if(auctioneer.bid > highest_bid)
			highest_bid = auctioneer.bid
			highest_bidder = auctioneer.name

	if(current_user)
		data["money"] = current_user.account_balance
	data["auction_item_name"] = current_item ? current_item.name : "Come Back Later."
	data["auction_item_desc"] = current_item ? current_item.desc : "No item is currently being auctioned."
	data["highest_bid"] = highest_bid
	data["highest_bidder"] = highest_bidder

	return data

/obj/item/market_uplink/auction/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("bid")
			var/new_bid = params["bid"]
			if(new_bid < 0)
				return
			for(var/datum/auctioneer/auctioneer in SSblackmarket.auction_bids)
				if(auctioneer.bidder == usr)
					auctioneer.update_bid(usr, new_bid)
					return



/**
 * A datum that holds the auction bidders that are currently being bid on for the black market.
 */
/datum/auctioneer
	/// Name of the auctioneer on the market. This is not the player's name, but a randomized ananymous name.
	var/name
	/// The reference to the real mob that was last bidding on the auction. If null, the auctioneer is an AI.
	var/datum/weakref/bidder
	/// The amount of money the auctioneer has bid on the auction. If this integer is the highest of an auction, the bidder will win the auction and the item is delivered to the bidder.
	var/bid = 0

/datum/auctioneer/New(mob/living/carbon/human/user, starting_bid)
	var/adjective = pick("Spotless", "Gentle", "Ironclad", "Baseless", "Inexcusable", "Fortuitous", "Cromulent", "Eldritch", "Biddle")
	var/noun = pick("Tiger", "Kiwi", "Grape", "Penguin", "Artifact", "Forest", "Chef", "Pirate", "Revolutionary", "Intelligence")
	var/chaser_noun = pick("Impact", "Radiant", "Zero", "Guardian", "Spector", "Whistle", "Origin", "Gamble", "Comedian", "Fortress")
	name = "[adjective] [noun] [chaser_noun]"

	if(user)
		bidder = WEAKREF(user)

	if(starting_bid)
		bid = starting_bid
	SSblackmarket.auction_bids += src

/datum/auctioneer/proc/update_bid(mob/living/carbon/human/user, new_bid)
	if(new_bid <= bid)
		return FALSE //You're not bidding more than you were before!

	var/highest_bid = 0
	for(var/datum/auctioneer/bidder in SSblackmarket.auction_bids)
		if(bidder.bid > highest_bid)
			highest_bid = bidder.bid

			if(highest_bid >= new_bid)
				return FALSE //You're not bidding more than the highest bid!

	bid = new_bid
	bidder = WEAKREF(user)
