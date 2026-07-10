// Bidding strategies
/// Aggressive: Will try and bid aggressively and response quickly for the first 30 seconds of the auction, but slow down for the last 30.
#define STRATEGY_AGGRESSIVE "aggressive"
/// Sniper: Will try and bid aggressively and responds quickly for the last 30 seconds of the auction, but slow for the first 30.
#define STRATEGY_SNIPER "sniper"
/// Hater: Starts When a new ite
#define STRATEGY_HATER "asshole"
/// Knockout: Will start off with a single, big bet to scare off competition, but only follow up with minimum bids.
#define STRATEGY_KNOCKOUT "knockout"
/// True Random: Flip flops between small, minimum bids, and large, random jumps, for the entire auction. The default strategy.
#define STRATEGY_RANDOM "random"
/// Player: Do nothing! This exists as a holder for the player's name and real bids more than anything, but the player will be able to blend in with AI bidders.
#define STRATEGY_PLAYER "player"

/// The auction is not running, or has not been started yet.
#define BID_IDLE "idle"
/// This auctioneer is currently active and still attempting to place bids.
#define BID_ACTIVE "active"
/// Not sure yet.
// #define BID_FIGHTING "fighting"
/// This auctioneer, through it's own logic or another auctioneer's logic, is no longer bidding until the next auction.
#define BID_RETIRED "retired"

/datum/auctioneer
	/// Name to be displayed within the auction interface. Randomized on init from a json list of options.
	var/name = "placeholder bidholeio"
	/// How much money does this auctioneer have? Budget will fluctuate over time in order to change how bids are placed.
	var/account_budget = 0
	/// What strategy will this auctioneer use when bidding?
	var/strategy = STRATEGY_RANDOM
	/// What item will this auctioneer prefer to buy? Preferred items will use 100% of the auctioneer's budget to buy, compared to other items which will use at most 50%.
	var/preferred_item

	/// What is this auctioneer's current status?
	var/bid_status = BID_IDLE
	/// If this auctioneer has placed a bid, what is their most recent bid value at?
	var/current_bid = 0
	/// Within the current auction, what is the soft limit that this AI will bid up to? Can be flexible based on strategy. Resets every auction.
	var/soft_limit = 0

/datum/auctioneer/New()
	. = ..()
	var/adjective = pick(GLOB.adjectives)
	var/noun = pick(GLOB.operative_aliases)
	name = "[adjective] [noun]"
	account_budget = rand(400,750)

/datum/auctioneer/proc/start_bidding()
	// First, we need to pick a value for how high of a bid the auctioneer can place without their AI getting in the way.
	soft_limit = 0 //Also reset this as we enter a new auction with a new budget.
	var/preferred = FALSE
	if(preferred_item == ssauction.current_auction_item())
		soft_limit = account_budget * (rand(60,100) / 100)
		preferred = TRUE
	else
		soft_limit = account_budget * (rand(40,70) / 100)
	to_chat(world, "Soft limit for [name] set to [soft_limit]. [preferred : "This is their preferred item!" ? "Normal rules."]")
	current_bid = rand(ssauction.minimum_bid)

///Here we handle all the logic and processing of each auctioneer.
/datum/auctioneer/proc/handle_bidding()
	if(bid_status == BID_RETIRED || bid_status == BID_IDLE)
		return FALSE// early return in cases where we have stopped bidding, or there is no auction.
	var/current_auction_price = ssauction.highest_bidder()
	if(current_auction_price >= soft_limit || (current_auction_price + SSauction.minimum_bid) > soft_limit)
		bid_status = BID_RETIRED
		to_chat(world,"I, [name] have been busted! I will only spend [soft_limit], not [current_auction_price]!")
		return FALSE
	//This means that we have money to spend, and we can still be the auction winner per my own rules.
	var/proposed_bid = generate_new_bid(current_auction_price)
	if(proposed_bid > account_budget || proposed_bid > soft_limit)
		bid_status = BID_RETIRED
	SSauction.auctioneers[src] = proposed_bid
	return TRUE

/// Proc where the auctioneer generates a new bid for the current auction, based on their strategy.
/datum/auctioneer/proc/generate_new_bid(current_auction_price)
	var/bid_proposal = abs(gaussian(0, SSauction.minimum_bid + (SSauction.minimum_bid * (rand(1,10)/10) )))
	bid_proposal = clamp(bid_proposal, current_auction_price + SSauction.minimum_bid, soft_limit)
	return bid_proposal

//Todo: implement these one at a time, but random is a good starting point.
// /datum/auctioneer/aggressive
// 	strategy = STRATEGY_AGGRESSIVE

// /datum/auctioneer/sniper
// 	strategy = STRATEGY_SNIPER

// /datum/auctioneer/hater
// 	strategy = STRATEGY_HATER

// /datum/auctioneer/knockout
// 	strategy = STRATEGY_KNOCKOUT

