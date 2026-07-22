
#define AUCTION_IDLE (1<<0) //Auction is not running.
#define AUCTION_EARLY (1<<1) // Auction is within the first half of it's 60 second duration.
#define AUCTION_LATE (1<<2) // Auction is in the last half of it's 60 second duration.
#define AUCTION_OVERTIME (1<<3) // Auction is finishing up.

#define AUCTIONEER_PAYCHECK_STANDARD 200

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

