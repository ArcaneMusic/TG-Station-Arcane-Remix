/obj/structure/ore_vent
	name = "ore vent"
	desc = "An ore vent, brimming with underground ore. Scan with an advanced mining scanner to start extracting ore from it."
	icon = 'icons/obj/mining_zones/terrain.dmi' /// note to self, new sprites. get on it
	icon_state = "geyser"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE

	/// Has this vent been tapped to produce boulders? Cannot be untapped.
	var/tapped = FALSE
	/// A weighted list of what minerals are contained in this vent, with weight determining how likely each mineral is to be picked in produced boulders.
	var/list/mineral_breakdown = list(
		/datum/material/iron = 30,
		/datum/material/glass = 30,
		/datum/material/titanium = 10,
		/datum/material/silver = 5,
		/datum/material/gold = 5,
		/datum/material/plasma = 5,
		/datum/material/diamond = 5,
		/datum/material/uranium = 5,
		/datum/material/bluespace = 1,
		/datum/material/plastic = 1,
	)
	var/static/list/lavaland_mobs = list(
		/mob/living/basic/mining/goliath,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher,
		/mob/living/simple_animal/hostile/asteroid/lobstrosity/lava,
		/mob/living/simple_animal/hostile/asteroid/brimdemon,
		/mob/living/basic/mining/bileworm
	)
	/// How many rolls on the mineral_breakdown list are made per boulder produced? EG: 3 rolls means 3 minerals per boulder, with order determining percentage.
	var/minerals_per_boulder = 3

	/// What size boulders does this vent produce?
	var/boulder_size = BOULDER_SIZE_SMALL

	/// Reference to this ore vent's NODE drone, to track wave success.
	var/mob/living/basic/node_drone/node = null //this path is a placeholder.

	/// Percent chance that this vent will produce an artifact as well.
	// var/artifact_chance = 0


/obj/structure/ore_vent/Initialize(mapload)
	if(tapped)
		SSore_generation.processed_vents += src
	. = ..()
	///This is the part where we start processing to produce a new boulder over time.

/obj/structure/ore_vent/Destroy()
	. = ..()
	if(tapped)
		SSore_generation.processed_vents -= src

/obj/structure/ore_vent/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/t_scanner/adv_mining_scanner))
		///This is where we start spitting out mobs.
		Shake(duration = 3 SECONDS)
		node = new /mob/living/basic/node_drone(loc)

		for(var/i in 1 to 5) // Clears the surroundings of the ore vent before starting wave defense.
			for(var/turf/closed/mineral/rock in oview(i))
				if(istype(rock, /turf/open/misc/asteroid) && prob(45)) // so it's too common
					new /obj/effect/decal/cleanable/rubble(rock)
				if(!istype(rock, /turf/closed/mineral))
					continue
				rock.gets_drilled(user, FALSE)
				new /obj/effect/decal/cleanable/rubble(rock)
			sleep(0.6 SECONDS)

		start_wave_defense()
		//This vent is going to start generating ore automatically.

/obj/structure/ore_vent/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	if(tapped)
		return FALSE
	if(istype(M, /mob/living/basic/node_drone))
		return TRUE

/**
 * Picks n types materials to pack into a boulder created by this ore vent, where n is this vent's minerals_per_boulder.
 * Then assigns custom_materials based on boulder_size, assigned via the ore_quantity_function
 */
/obj/structure/ore_vent/proc/create_mineral_contents()

	var/list/refined_list = list()
	for(var/iteration in 1 to minerals_per_boulder)
		var/datum/material/material = pick_weight(mineral_breakdown)
		refined_list.Insert(refined_list.len, material)
		refined_list[material] += ore_quantity_function(iteration)
	return refined_list

/**
 * Returns the quantity of mineral sheets in each ore's boulder contents roll. First roll can produce the most ore, with subsequent rolls scaling lower logarithmically.
 */
/obj/structure/ore_vent/proc/ore_quantity_function(ore_floor)
	var/mineral_count = boulder_size * (log(rand(1+ore_floor, 4+ore_floor))**-1)
	mineral_count = SHEET_MATERIAL_AMOUNT * round(mineral_count)
	say("[mineral_count] is the count!")
	return mineral_count

/**
 * Starts the wave defense event, which will spawn a number of lavaland mobs based on the size of the ore vent.
 * Called after the vent has been tapped by a scanning device.
 * Will summon a number of waves of mobs, ending in the vent being tapped after the final wave.
 */
/obj/structure/ore_vent/proc/start_wave_defense()
	//faction = FACTION_MINING,	//todo: is there some reason I can't sanity check mob faction?
	AddComponent(/datum/component/spawner,\
		spawn_types = lavaland_mobs,\
		spawn_time = 15 SECONDS,\
		max_spawned = 10,\
		spawn_per_attempt = (1 + (boulder_size/5)),\
		spawn_text = "emerges to assault",\
		spawn_distance = 4,\
		spawn_distance_exclude = 3)
	var/wave_timer = 20 SECONDS
	if(boulder_size == BOULDER_SIZE_MEDIUM)
		wave_timer = 40 SECONDS
	else if(boulder_size == BOULDER_SIZE_LARGE)
		wave_timer = 60 SECONDS

	addtimer(CALLBACK(src, PROC_REF(handle_wave_conclusion)), wave_timer)

/obj/structure/ore_vent/proc/handle_wave_conclusion()
	if(node) ///Can we check if any mobs are still alive?
		//This is where we'd send a signal to the ore vent to remove it's spawner component.
		tapped = TRUE
		SSore_generation.processed_vents += src
	else
		//Wave defense is failed, and the ore vent downgrades one tier, capping at small.
		if(boulder_size == BOULDER_SIZE_LARGE)
			boulder_size = BOULDER_SIZE_MEDIUM
			visible_message(span_danger("\the [src] crumbles as the mining attempt fails, and the ore vent partially closes up!"))
		else if(boulder_size == BOULDER_SIZE_MEDIUM)
			boulder_size = BOULDER_SIZE_SMALL
			visible_message(span_danger("\the [src] crumbles as the mining attempt fails, and the ore vent is left damaged!"))
		else
			visible_message(span_danger("\the [src] creaks and groans as the mining attempt fails, but stays it's current size."))
	SEND_SIGNAL(src, COMSIG_MINING_SPAWNER_STOP)
	for(var/potential_miner as anything in oview(5))
		if(ishuman(potential_miner))
			var/mob/living/carbon/human/true_miner = potential_miner
			var/obj/item/card/id/user_id_card = true_miner.get_idcard(TRUE)
			if(!user_id_card)
				continue
			if(user_id_card)
				user_id_card.registered_account.mining_points += (MINER_POINT_MULTIPLIER * boulder_size)

/obj/structure/ore_vent/starter_resources
	name = "active ore vent"
	desc = "An ore vent, brimming with underground ore. It's already supplying the station with iron and glass."
	tapped = TRUE
	mineral_breakdown = list(
		/datum/material/iron = 50,
		/datum/material/glass = 50,
	)

/obj/structure/ore_vent/medium
	boulder_size = BOULDER_SIZE_MEDIUM

/obj/structure/ore_vent/large
	boulder_size = BOULDER_SIZE_LARGE


/obj/item/boulder
	name = "boulder"
	desc = "This rocks."
	icon_state = "ore"
	icon = 'icons/obj/ore.dmi'
	item_flags = NO_MAT_REDEMPTION
	///When a refinery machine is working on this boulder, we'll set this. Re reset when the process is finished, but the boulder may still be refined/operated on further.
	var/obj/machinery/bouldertech/processed_by = null

/obj/item/boulder/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 0, force_wielded = 5) //Heavy as all hell, it's a boulder, dude.

/obj/item/boulder/Destroy(force)
	. = ..()
	SSore_generation.available_boulders -= src
