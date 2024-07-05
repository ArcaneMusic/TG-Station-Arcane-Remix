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

