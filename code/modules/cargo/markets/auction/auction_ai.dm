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

/datum/auctioneer
	/// Name to be displayed within the auction interface. Randomized on init from a json list of options.
	var/name = "placeholder"
	/// How much money does this auctioneer have? Budget will fluctuate over time in order to change how bids are placed.
	var/account_budget
	/// What strategy will this auctioneer use when bidding?
	var/strategy
	/// What item will this auctioneer prefer to buy? Preferred items will use 100% of the auctioneer's budget to buy, compared to other items which will use at most 50%.
	var/preferred_item


