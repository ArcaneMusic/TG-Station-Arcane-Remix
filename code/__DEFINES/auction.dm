
///Auction is not running.
#define AUCTION_IDLE "idle"
/// Auction is within the first half of it's 60 second duration.
#define AUCTION_EARLY "early"
/// Auction is in the last half of it's 60 second duration.
#define AUCTION_LATE "late"
/// Auction is finishing up.
#define AUCTION_OVERTIME "overtime"

#define AUCTIONEER_PAYCHECK_STANDARD 200

#define BIDDING_CD_RAPID 2 SECONDS
#define BIDDING_CD_NORMAL 4 SECONDS
#define BIDDING_CD_SLOW 8 SECONDS

// Bidding strategies
/// Aggressive: Will try and bid aggressively and response quickly for the first 30 seconds of the auction, but idles for the last 30.
#define STRATEGY_AGGRESSIVE "aggressive"
/// Sniper: Will try and bid aggressively and responds quickly for the last 30 seconds of the auction, but idles for the first 30.
#define STRATEGY_SNIPER "sniper"
/// Hater: Picks a bidder every auction who it will aggressively try to outbid, and ONLY them.
#define STRATEGY_HATER "asshole"
/// Knockout: Will start off with a single, big bet to scare off competition, but only follow up with minimum bids.
#define STRATEGY_KNOCKOUT "knockout"
/// True Random: Flip flops between small, minimum bids, and large, random jumps, for the entire auction. The default strategy.
#define STRATEGY_RANDOM "random"
/// Player: Do nothing! This exists as a holder for the player's name and real bids more than anything, but the player will be able to blend in with AI bidders.
#define STRATEGY_PLAYER "player"

/// This auctioneer is not retired, but is not currently active.
#define BID_IDLE "idle"
/// This auctioneer is currently active and still attempting to place bids.
#define BID_ACTIVE "active"
/// This auctioneer, through it's own logic or another auctioneer's logic, is no longer bidding until the next auction.
#define BID_RETIRED "retired"

