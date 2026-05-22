#define AUCTION_IDLE (1<<0) //Auction is not running.
#define AUCTION_EARLY (1<<1) // Auction is within the first half of it's 60 second duration.
#define AUCTION_LATE (1<<2) // Auction is in the last half of it's 60 second duration.
#define AUCTION_OVERTIME (1<<3) // Auction is finishing up.

/// The subsystem used to process auctions. Only starts running when a market uplink is created and accessed for the first time.
PROCESSING_SUBSYSTEM_DEF(auction)
	name = "Auction"
	wait = 1 SECONDS
	/// List of all initialized auctioneer AIs
	var/auctioneers = list()
	/// List of items that are available to bid on. This list is order specific, the first entry in the list is the current auction.
	var/list/auction_items = list()
	/// What is the current minimum bid?
	var/minimum_bid = 10
	/// Current status of the auction house. Make defines but for now I'm being lazy.
	var/auction_status = AUCTION_IDLE
	COOLDOWN_DECLARE(auction_duration)
	COOLDOWN_DECLARE(auction_break)

/datum/controller/subsystem/auction/Initialize()
	init_subtypes(/datum/auctioneer, auctioneers)

/datum/controller/subsystem/auction/fire(resumed)
	// Auction is taking a break between items. Nothing to do.
	if(!COOLDOWN_FINISHED(src, auction_break))
		return

	// Setup a new auction, both for bidders and for the SubSystem.
	if(auction_status & AUCTION_IDLE)
		for(var/datum/auctioneer/bidder in auctioneers)
			bidder.start_bidding()
		COOLDOWN_START(src, auction_duration, 65 SECONDS)
		auction_status = AUCTION_EARLY
		return

	// If we've reached here, handle the bidding.
	for(var/datum/auctioneer/bidder in auctioneers)
		bidder.handle_bidding()

	// Here we mature either the auction status...
	if(auction_status & AUCTION_EARLY)
		if(COOLDOWN_TIMELEFT(src, auction_duration) <= 30 SECONDS)
			auction_status = AUCTION_LATE
			return

	if(auction_status & AUCTION_LATE)
		if(COOLDOWN_TIMELEFT(src, auction_duration) <= 5 SECONDS)
			auction_status = AUCTION_OVERTIME
			return

	// Or, we determine the auction winner (When we are now within AUCTION_OVERTIME status.)
	if(COOLDOWN_FINISHED(src, auction_duration))
		var/datum/auctioneer/winner = highest_bidder()
		if(winner.strategy == STRATEGY_PLAYER)
			//This is where we handle a player winning the auction.
			return
		if(winner.current_bid > winner.account_budget)
			CRASH("WE COMITTED FRAUD!!")
		winner.account_budget -= winner.current_bid
		


/datum/controller/subsystem/auction/proc/current_auction_item()
	var/datum/market_item/item_datum = auction_items[0]
	if(!item_datum.item)
		CRASH("There was no item within the item datum to return! Is that normal?")
	return item_datum.item

/// Sorts the current bidders, picks the highest bidder.
/datum/controller/subsystem/auction/proc/highest_bidder()
	var/datum/auctioneer/highest_bidder
	var/highest_bid = 0
	for(var/datum/auctioneer/bidder in auctioneers)
		if(bidder.current_bid > highest_bid)
			highest_bidder = bidder
			highest_bid = highest_bidder.current_bid
	return highest_bidder
