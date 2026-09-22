// For defines, see code\__DEFINES\auction.dm.

/datum/auctioneer
	/// Name to be displayed within the auction interface. Randomized on init from a json list of options.
	var/name = "placeholder bidholeio"
	/// How much money does this auctioneer have? Budget will fluctuate over time in order to change how bids are placed.
	var/account_budget = 0
	/// What strategy will this auctioneer use when bidding?
	var/strategy = STRATEGY_RANDOM
	/// What item will this auctioneer prefer to buy? Preferred items will use 100% of the auctioneer's budget to buy, compared to other items which will use at most 50%.
	var/preferred_item //todo: preferred category of item?
	/// What is the bidding delay of our actioneer? Modifier by strategy, as well as preferred bid.
	var/bidding_delay = BIDDING_CD_NORMAL

	/// What is this auctioneer's current status?
	var/bid_status = BID_IDLE
	/// If this auctioneer has placed a bid, what is their most recent bid value at?
	var/current_bid = 0
	/// Within the current auction, what is the soft limit that this AI will bid up to? Can be flexible based on strategy. Resets every auction.
	var/soft_limit = 0
	COOLDOWN_DECLARE(bid_cd)

/datum/auctioneer/New()
	. = ..()
	var/adjective = capitalize(pick(GLOB.adjectives))
	var/noun = pick(GLOB.operative_aliases)
	name = "[adjective] [noun]"
	account_budget = rand(400,750)
	LAZYADD(SSauction.auctioneers, src)
	if(!length(SSauction.auction_items))
		return
	preferred_item = pick(SSauction.auction_items) //Every auctioneer should want something.

/// Handles how auctioneers setup their bidding strategy, budget, and cooldowns before the auction starts.
/datum/auctioneer/proc/start_bidding(var/starting_bid_value = 10)
	// First, we need to pick a value for how high of a bid the auctioneer can place without their AI getting in the way.
	var/preferred = FALSE
	if(preferred_item == SSauction.current_auction_item())
		soft_limit = account_budget * (rand(60, 100) / 100)
		preferred = TRUE
		bidding_delay = BIDDING_CD_RAPID
	else
		soft_limit = account_budget * (rand(40, 70) / 100)
		bidding_delay = BIDDING_CD_NORMAL
	soft_limit = round(soft_limit)
	to_chat(world, "Soft limit for [name] set to [soft_limit]. [preferred ? "This is their preferred item!" : "Normal rules."]")
	current_bid = rand(SSauction.minimum_bid, 3 * SSauction.minimum_bid)
	current_bid = max(current_bid, starting_bid_value)
	if(current_bid > soft_limit)
		//Welp, we're outbid on this one...
		to_chat(world, "I, [name], am automatically disqualified! Too rich for my blood.")
		bid_status = BID_RETIRED
		return
	to_chat(world, "[name]'s starting bid is [current_bid], on strategy [strategy]")
	reset_cooldown(src, bid_cd)
	bid_status = BID_ACTIVE

///Here we handle all the logic and processing of each auctioneer.
/datum/auctioneer/proc/handle_bidding()
	if(bid_status == BID_RETIRED)
		return FALSE // early return in cases where we have stopped bidding, or there is no auction.
	if(!COOLDOWN_FINISHED(src, bid_cd))
		return FALSE //Don't bid until the cooldown has passed.
	var/datum/auctioneer/highest_bidder = SSauction.highest_bidder()
	if(highest_bidder == src)
		to_chat(world, "[name] is already winning, no need to bid.")
		COOLDOWN_START(src, bid_cd, bidding_delay + (rand(1,3) SECONDS)) //restart their delay, but without randomness
		return FALSE //We're already winning! No need to move.
	var/current_auction_price = SSauction.highest_bid()
	if(current_auction_price >= soft_limit || (current_auction_price + SSauction.minimum_bid) > soft_limit)
		bid_status = BID_RETIRED
		to_chat(world,"I, [name] have been busted! I will only spend [soft_limit], not [current_auction_price]!")
		return FALSE
	//This means that we have money to spend, and we can still be the auction winner per my own rules.
	var/proposed_bid = generate_new_bid(current_auction_price)
	if(proposed_bid > account_budget || proposed_bid > soft_limit)
		to_chat(world, "Woe be [name], I won't bid high enough to win! I'm out!")
		bid_status = BID_RETIRED
		return FALSE
	to_chat(world, "I, [name], will bid [proposed_bid] for this bidding cycle!")
	current_bid = proposed_bid
	COOLDOWN_START(src, bid_cd, bidding_delay + (rand(1,3) SECONDS))
	return TRUE

/// Proc where the auctioneer generates a new bid for the current auction, based on their strategy.
/datum/auctioneer/proc/generate_new_bid(current_auction_price)
	var/bid_proposal = round(abs(gaussian(0, (SSauction.minimum_bid * (rand(10, 110)/10) )))) //Random just adds a neat little
	bid_proposal = clamp(bid_proposal + current_auction_price, current_auction_price + SSauction.minimum_bid, soft_limit)
	return bid_proposal

//Todo: implement these one at a time, but random is a good starting point.
/datum/auctioneer/aggressive
	strategy = STRATEGY_AGGRESSIVE

/datum/auctioneer/aggressive/generate_new_bid(current_auction_price)
	var/bid_proposal = 0
	switch(SSauction.auction_status)
		if(AUCTION_EARLY)
			bid_proposal = round(abs(gaussian(0, (SSauction.minimum_bid * (rand(30, 60)/10) )))) //Large, agressive bids early!
		if(AUCTION_LATE)
			bid_proposal = round(abs(gaussian(0, (SSauction.minimum_bid * (rand(10, 15)/10) )))) //And weak, baby bids by the end.
		if(AUCTION_OVERTIME)
			bid_status = BID_RETIRED //And if they haven't won by overtime, they're giving up.
			return FALSE
	bid_proposal = clamp(bid_proposal + current_auction_price, current_auction_price + SSauction.minimum_bid, soft_limit)
	return bid_proposal

/datum/auctioneer/sniper
	strategy = STRATEGY_SNIPER

/datum/auctioneer/sniper/generate_new_bid(current_auction_price)
	var/bid_proposal = 0
	switch(SSauction.auction_status)
		if(AUCTION_EARLY)
			bid_status = BID_IDLE // Lies in wait in the early stages.
			return FALSE // not bidding at all, but not retiring.
		if(AUCTION_LATE)
			bid_proposal = round(abs(gaussian(0, (SSauction.minimum_bid * (rand(30, 60)/10) )))) //Large, agressive bids late!
		if(AUCTION_OVERTIME)
			bid_proposal = round(abs(gaussian(0, (SSauction.minimum_bid * (rand(10, 15)/10) )))) //Peppering with weaker bids to seal the deal if they can manage it.
			return FALSE
	bid_proposal = clamp(bid_proposal + current_auction_price, current_auction_price + SSauction.minimum_bid, soft_limit)
	return bid_proposal

/datum/auctioneer/hater
	strategy = STRATEGY_HATER
	/// We pick another auctioneer and we make them our most vile enemy. We don't care that much about winning, as long as they LOSE.
	var/datum/auctioneer/enemy

/datum/auctioneer/hater/start_bidding(starting_bid_value)
	. = ..()
	enemy = pick(SSauction.auctioneers)
	if(!enemy)
		bid_status = BID_IDLE //We have nothing to bid for if not for our SPITE.

/datum/auctioneer/hater/generate_new_bid(current_auction_price)
	var/bid_proposal = 0
	if(enemy.bid_status == BID_RETIRED)
		src.bid_status = BID_RETIRED //Our work here is done.
		return FALSE
	if(enemy == SSauction.highest_bidder())
		//OH YOU DONE DID IT NOW
		bid_proposal = SSauction.highest_bid() + SSauction.minimum_bid
	else if(enemy.bid_status == BID_IDLE)
		bid_proposal = round(abs(gaussian(0, (SSauction.minimum_bid * (rand(10, 15)/10) )))) // You never know if our enemy is going to show back up again.
	bid_proposal = clamp(bid_proposal + current_auction_price, current_auction_price + SSauction.minimum_bid, soft_limit)
	return bid_proposal

/datum/auctioneer/knockout
	strategy = STRATEGY_KNOCKOUT

/datum/auctioneer/knockout/generate_new_bid(current_auction_price)
	var/bid_proposal = 0
	if(prob(50) && (SSauction.current_auction_item() != preferred_item))
		//Ehh, not worth the effort
		src.bid_status = BID_RETIRED
		return FALSE
	bid_proposal = clamp(bid_proposal * 2, current_auction_price, soft_limit) //We're going to keep LITERALLY doubling down until we win.
	return bid_proposal

// Todo: Split up pre-bid checks out of generate new bids and instead just add a generalized status check instead. Probably shouldn't return FALSE when making a bid
// todo: Why are we getting 2 auctioneers of each type?
// todo: How do we not homogenize the costs of the different items? Should some auction AI decide NOT to bid on something if they can't afford their preferred item?
// todo: yeah we're at UI stage. Too much info per auction now.
