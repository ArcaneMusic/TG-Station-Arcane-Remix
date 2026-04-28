/// The subsystem used to process auctions. Only starts running when a market uplink is created and accessed for the first time.
PROCESSING_SUBSYSTEM_DEF(auction)
	name = "Auction"
	wait = 1 SECONDS
	var/auctioneers = list()

/datum/controller/subsystem/auction/Initialize()
	. = ..()
	init_subtypes(/datum/auctioneer, auctioneers)
