

/datum/market/auction
	name = "Auction"
	shipping = list(
		SHIPPING_METHOD_LTSRBT = 40,
		SHIPPING_METHOD_LAUNCH = 10,
		SHIPPING_METHOD_TELEPORT= 75,
	)
	/// The order-specific list of the items being auctioned. Key 0 is the current item being auctioned, and after that are the items in the queue.
	var/datum/list/auction_queue = list()

/datum/market/auction/purchase(identifier, category, method, obj/item/market_uplink/uplink, user)
	. = ..()
	if(!.)
		return
	var/datum/market_item/item = available_items[category][identifier]
	SSblackmarket.auction_weights -= item
	to_chat(world, "successfully removed [item] from weights!")


/datum/market/auction/add_item(datum/market_item/item)
	auction_queue[length(auction_queue)] += item
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
		for(var/datum/auctioneer/auction_options in SSblackmarket.auction_bids)
			if(auction_options.bidder == user)
				return
		// We don't exist as an auctioneer yet, roll out
		var/datum/auctioneer = new(user, 0)
		SSblackmarket.auction_bids += auctioneer

// /obj/item/market_uplink/auction/ui_data(mob/user)
// 	var/list/data = list()
// 	data["auction_item"] = list()

// 	var/datum/market/auction/prime_auction = SSblackmarket.markets[/datum/market/auction]
// 	var/datum/market_item/current_item = prime_auction[id]

// 	data["auction_item"] += list(list(
// 		"id" = id,
// 		"name" = item.name,
// 		"cost" = item.price,
// 		"amount" = item.stock,
// 		"desc" = item.desc || item.name
// 	))
// 	return data


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
		return
	bid = new_bid
	bidder = WEAKREF(user)

