
/// The subsystem used to process auctions. Only starts running when a market uplink is created and accessed for the first time.
SUBSYSTEM_DEF(auction)
	name = "Auction"
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME
	/// List of all initialized auctioneer AIs
	var/list/auctioneers = list()
	/// List of items that are available to bid on. This list is order specific, the first entry in the list is the current auction.
	var/list/auction_items = list()
	/// What is the current minimum bid?
	var/minimum_bid = 10
	/// What is the starting bid on the current acution item?
	var/starting_bid = 10
	/// Current status of the auction house. Make defines but for now I'm being lazy.
	var/auction_status = AUCTION_IDLE
	COOLDOWN_DECLARE(auction_duration)
	COOLDOWN_DECLARE(auction_break)

/datum/controller/subsystem/auction/Initialize()
	// auctioneers = init_subtypes(/datum/auctioneer, list())
	auctioneers += new /datum/auctioneer
	auctioneers += new /datum/auctioneer
	auctioneers += new /datum/auctioneer/aggressive
	auctioneers += new /datum/auctioneer/sniper
	auctioneers += new /datum/auctioneer/hater
	auctioneers += new /datum/auctioneer/knockout
	if(auction_items)
		auction_items = shuffle(auction_items)
	else
		to_chat(world, "I was too early! Nothing to shuffle.")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/auction/fire(resumed)
	// Auction is taking a break between items. Nothing to do.
	if(!COOLDOWN_FINISHED(src, auction_break))
		to_chat(world, "Bidding is on hold. Sorry for the spam.")
		return

	// Setup a new auction, both for bidders and for the SubSystem.
	if(auction_status == AUCTION_IDLE)
		for(var/datum/auctioneer/bidder in auctioneers)
			bidder.start_bidding(starting_bid)
		COOLDOWN_START(src, auction_duration, 65 SECONDS)
		auction_status = AUCTION_EARLY
		return

	// If we've reached here, handle the bidding.
	for(var/datum/auctioneer/bidder in auctioneers) //First we loop all the auctioneers logic to generate a new bid
		if(bidder.handle_bidding() && auction_status == AUCTION_OVERTIME)
			COOLDOWN_START(src, auction_duration, 5 SECONDS)
	for(var/datum/auctioneer/bidder in auctioneers) //Second, we perform a second loop so that they actually comit the bid, that way there's a time delay as they go back n forth.
		SSauction.auctioneers[bidder] = bidder.current_bid

	// Here we mature either the auction status...
	if(auction_status == AUCTION_EARLY)
		if(COOLDOWN_TIMELEFT(src, auction_duration) <= 30 SECONDS)
			auction_status = AUCTION_LATE
			to_chat(world, span_bold("THE AUCTION IS ENTERING THE LATE STAGE"))
			return

	if(auction_status == AUCTION_LATE)
		if(COOLDOWN_TIMELEFT(src, auction_duration) <= 5 SECONDS)
			auction_status = AUCTION_OVERTIME
			to_chat(world, span_bold("THE AUCTION IS ENTERING OVERTIME"))
			return

	// Or, we determine the auction winner (When we are now within AUCTION_OVERTIME status.)
	if(COOLDOWN_FINISHED(src, auction_duration))
		handle_auction_conclusion()

/datum/controller/subsystem/auction/proc/current_auction_item()
	if(!length(auction_items))
		return FALSE
	var/datum/market_item/item_datum = auction_items[1]
	if(!item_datum.item)
		CRASH("There was no item within the item datum to return! Is that normal?")
	return item_datum

/// Sorts the current bidders, picks the highest bidder.
/datum/controller/subsystem/auction/proc/highest_bidder()
	var/datum/auctioneer/highest_bidder
	var/highest_bid = 0
	for(var/datum/auctioneer/bidder in auctioneers)
		if(auctioneers[bidder] > highest_bid)
			highest_bidder = bidder
			highest_bid = auctioneers[bidder]
	return highest_bidder

/// Sorts the current bidders, returns the highest placed bid.
/datum/controller/subsystem/auction/proc/highest_bid()
	var/highest_bid = 0
	for(var/datum/auctioneer/bidder in auctioneers)
		if(auctioneers[bidder] > highest_bid)
			highest_bid = auctioneers[bidder]
	return highest_bid

/datum/controller/subsystem/auction/proc/reset_bids()
	for(var/datum/auctioneer/bidder in auctioneers)
		auctioneers[bidder] = 0
		bidder.current_bid = 0
		bidder.soft_limit = 0 //Also reset this as we enter a new auction with a new budget.
		bidder.account_budget += AUCTIONEER_PAYCHECK_STANDARD // and refill everyone's coffers before we get started.

/datum/controller/subsystem/auction/proc/handle_auction_conclusion()
	var/datum/auctioneer/winner = highest_bidder()
	if(winner.strategy == STRATEGY_PLAYER)
		//This is where we handle a player winning the auction, and presumably getting the item.
		to_chat(world, "Player won!")
	else
		to_chat(world, "AI auctioneer won! Refreshing item.")
		pop_append(auction_items) // Move to the tail end of the list.
	if(auctioneers[winner] > winner.account_budget)
		CRASH("WE COMITTED FRAUD!!")

	winner.account_budget -= winner.current_bid
	auction_status = AUCTION_IDLE
	COOLDOWN_START(src, auction_break, 60 SECONDS)
	to_chat(world, "[winner.name] has won the auction with a bid of [auctioneers[winner]], against a soft limit of [winner.soft_limit]")
	reset_bids()
