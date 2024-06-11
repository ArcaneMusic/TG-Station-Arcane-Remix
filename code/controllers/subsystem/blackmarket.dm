SUBSYSTEM_DEF(blackmarket)
	name = "Blackmarket"
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_DEFAULT

	/// Descriptions for each shipping methods.
	var/shipping_method_descriptions = list(
		SHIPPING_METHOD_LAUNCH = "Launches the item at the station from space, cheap but you might not receive your item at all.",
		SHIPPING_METHOD_LTSRBT = "Long-To-Short-Range-Bluespace-Transceiver, a machine that receives items outside the station and then teleports them to the location of the uplink.",
		SHIPPING_METHOD_TELEPORT = "Teleports the item in a random area in the station, you get 60 seconds to get there first though.",
		SHIPPING_METHOD_SUPPLYPOD = "Ships the item inside a supply pod at your exact location. Showy, speedy and expensive.",
	)

	/// List of all existing markets.
	var/list/datum/market/markets = list()
	/// List of existing ltsrbts.
	var/list/obj/machinery/ltsrbt/telepads = list()
	/// Currently queued purchases.
	var/list/queued_purchases = list()

	/// Has someone opened an auction uplink somewhere? If so, we'll start running cooldowns to replace the item.
	var/auction_running = FALSE
	/// Weighted list of auction items to use with the auction black market.
	var/list/auction_weights = list()

/datum/controller/subsystem/blackmarket/Initialize()
	for(var/market in subtypesof(/datum/market))
		markets[market] += new market

	for(var/datum/market_item/item as anything in subtypesof(/datum/market_item))
		if(!initial(item.item))
			continue
		var/datum/market_item/item_instance = new item()
		if(prob(item_instance.availability_prob[/datum/market/blackmarket]))
			for(var/potential_market in item_instance.availability_prob) //Provide the market in the associated list.
				if(!markets[potential_market])
					stack_trace("SSblackmarket: Item [item_instance] available in market that does not exist.")
					continue
				// If this fails the market item will just be GC'd
				markets[potential_market].add_item(item_instance)
		if(item_instance.availability_prob[/datum/market/auction])
			for(var/potential_market in item_instance.availability_prob) //Provide the market in the associated list.
				if(!markets[potential_market])
					stack_trace("SSblackmarket: Item [item_instance] available in market that does not exist.")
					continue
				auction_weights[item_instance.type] = item_instance.availability_prob[/datum/market/auction]

	for(var/i in 1 to 2)
		markets[/datum/market/auction].add_item(pick_weight(auction_weights))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/blackmarket/fire(resumed)
	while(length(queued_purchases))
		var/datum/market_purchase/purchase = queued_purchases[1]
		queued_purchases.Cut(1,2)

		var/mob/buyer = recursive_loc_check(purchase.uplink.loc, /mob)

		switch(purchase.method)
			// Find a ltsrbt pad and make it handle the shipping.
			if(SHIPPING_METHOD_LTSRBT)
				if(!length(telepads))
					continue
				// Prioritize pads that don't have a cooldown active.
				var/obj/machinery/ltsrbt/lowest_cd_pad
				// The time left of the shortest cooldown amongst all telepads.
				var/lowest_timeleft = INFINITY
				for(var/obj/machinery/ltsrbt/pad as anything in telepads)
					if(!COOLDOWN_FINISHED(pad, recharge_cooldown))
						var/timeleft = COOLDOWN_TIMELEFT(pad, recharge_cooldown)
						if(timeleft < lowest_timeleft)
							lowest_cd_pad = pad
							lowest_timeleft = timeleft
						continue
					lowest_cd_pad = pad
					break

				lowest_cd_pad.add_to_queue(purchase)

				to_chat(buyer, span_notice("[purchase.uplink] flashes a message noting that the order is being processed by [lowest_cd_pad]."))

			// Get random area, throw it somewhere there.
			if(SHIPPING_METHOD_TELEPORT)
				var/turf/targetturf = get_safe_random_station_turf()
				// This shouldn't happen.
				if (!targetturf)
					continue
				queued_purchases -= purchase

				to_chat(buyer, span_notice("[purchase.uplink] flashes a message noting that the order is being teleported to [get_area(targetturf)] in 60 seconds."))

				// do_teleport does not want to teleport items from nullspace, so it just forceMoves and does sparks.
				addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/controller/subsystem/blackmarket,fake_teleport), purchase, targetturf), 60 SECONDS)

			// Get the current location of the uplink if it exists, then throws the item from space at the station from a random direction.
			if(SHIPPING_METHOD_LAUNCH)
				var/startSide = pick(GLOB.cardinals)
				var/turf/T = get_turf(purchase.uplink)
				var/pickedloc = spaceDebrisStartLoc(startSide, T.z)

				var/atom/movable/item = purchase.entry.spawn_item(pickedloc, purchase)
				item.throw_at(purchase.uplink, 3, 3, spin = FALSE)

				to_chat(buyer, span_notice("[purchase.uplink] flashes a message noting the order is being launched at the station from [dir2text(startSide)]."))
				qdel(purchase)

			if(SHIPPING_METHOD_SUPPLYPOD)
				var/obj/structure/closet/supplypod/back_to_station/pod = new()
				purchase.entry.spawn_item(pod, purchase)
				new /obj/effect/pod_landingzone(get_turf(purchase.uplink), pod)

				to_chat(buyer, span_notice("[purchase.uplink] flashes a message noting the order is being launched at your location. Right here, right now!"))
				qdel(purchase)

		if(MC_TICK_CHECK)
			break

/// Used to make a teleportation effect as do_teleport does not like moving items from nullspace.
/datum/controller/subsystem/blackmarket/proc/fake_teleport(datum/market_purchase/purchase, turf/target)
	// Oopsie, whoopsie, the item is gone. So long, and thanks for all the money.
	if(QDELETED(purchase))
		return
	var/atom/movable/thing = purchase.entry.spawn_item(target, purchase)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 1, target)
	sparks.attach(thing)
	sparks.start()
	qdel(purchase)

/// Used to add /datum/market_purchase to queued_purchases var. Returns TRUE when queued.
/datum/controller/subsystem/blackmarket/proc/queue_item(datum/market_purchase/purchase)
	if((purchase.method == SHIPPING_METHOD_LTSRBT && !telepads.len) || isnull(purchase.uplink))
		qdel(purchase)
		return FALSE
	queued_purchases += purchase
	return TRUE

/datum/controller/subsystem/blackmarket/proc/handle_auctions(next_auction_delay = 75 SECONDS)
	if(!auction_running)
		return FALSE
	if(!length(auction_weights))
		return FALSE

	///Go through the list of bids and find the highest one, then give the item to the highest bidder.

	addtimer(CALLBACK(src, PROC_REF(handle_auctions)), next_auction_delay)
	to_chat(world, span_notice("The auction black market is now open for business in [next_auction_delay / 10]!"))

	
