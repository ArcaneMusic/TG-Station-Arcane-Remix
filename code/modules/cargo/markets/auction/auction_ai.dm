// Bidding strategies
/// Aggressive: Will try and bid aggressively and response quickly for the first 30 seconds of the auction, but slow down for the last 30.
#define STRATEGY_AGGRESSIVE "aggressive"
/// Sniper: Will try and bid aggressively and responds quickly for the last 30 seconds of the auction, but slow for the first 30.
#define STRATEGY_SNIPER "sniper"
/// Hater: Starts When a new ite
#define STRATEGY_HATER "asshole"
/// Knockout: Will start off with a single, big bet to scare off competition, but only follow up with minimum bids.
#define STRATEGY_KNOCKOUT "knockout"
/// True Random: Flip flops between small, minimum bids, and large, random jumps, for the entire auction.
#define STRATEGY_RANDOM "random"
/// Player: Do nothing! This exists as a holder for the player's name and real bids more than anything, but the player will be able to blend in with AI bidders.
#define STRATEGY_PLAYER "player"

#define BID_IDLE "idle"
#define BID_ACTIVE "active"
#define BID_FIGHTING "fighting"
#define BID_RETIRED "retired"

/datum/auctioneer
	/// Name to be displayed within the auction interface. Randomized on init from a json list of options.
	var/name = "placeholder"
	/// How much money does this auctioneer have? Budget will fluctuate over time in order to change how bids are placed.
	var/account_budget
	/// What strategy will this auctioneer use when bidding?
	var/strategy
	/// What item will this auctioneer prefer to buy? Preferred items will use 100% of the auctioneer's budget to buy, compared to other items which will use at most 50%.
	var/preferred_item

	/// What is this auctioneer's current status?
	var/bid_status
	/// If this auctioneer has placed a bid, what is their most recent bid value at?
	var/current_bid = 0
	/// Within the current auction, what is the soft limit that this AI will bid up to? Can be flexible based on strategy. Resets every auction.


/datum/auctioneer/New()
	. = ..()
	var/adjective = pick(GLOB.adjectives)
	var/noun = pick(GLOB.operative_aliases)
	name = "[adjective] [noun]"
	account_budget = rand(400,750)

/datum/auctioneer/proc/start_bidding()
	// First, we need to pick a value for how high of a bid the auctioneer can place without their AI getting in the way.
	var/soft_limit = 0
	var/preferred = FALSE
	if(preferred_item == ssauction.current_auction_item())
		soft_limit = account_budget * (rand(60,80) / 100)
		preferred = TRUE
	else
		soft_limit = account_budget * (rand(40,70) / 100)
	to_chat(world, "Soft limit for [name] set to [soft_limit]. [preferred : "This is their preferred item!" ? "Normal rules."]")
	current_bid = rand(ssauction.minimum_bid)

///Here we handle all the logic and processing of each auctioneer.
/datum/auctioneer/proc/handle_bidding()



/datum/auctioneer/aggressive
	strategy = STRATEGY_AGGRESSIVE

/datum/auctioneer/sniper
	strategy = STRATEGY_SNIPER

/datum/auctioneer/hater
	strategy = STRATEGY_HATER

/datum/auctioneer/knockout
	strategy = STRATEGY_KNOCKOUT

/datum/auctioneer/random
	strategy = STRATEGY_RANDOM

