
/mob/living/basic/migrant
	name = "migrant"
	desc = "An interdimensional pest. They slip and glide across dimensions looking for tasty energy sources before they return back to the nether."
	icon_state = "migrant"
	icon_living = "migrant"
	icon_dead = "migrant_dead"

	maxHealth = 10
	health = 10
	density = FALSE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_MINERAL
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_NETHER, FACTION_MAINT_CREATURES)
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)

	speak_emote = list("chirps")
	response_help_continuous = "rubs"
	response_help_simple = "rub"
	response_harm_continuous = "crunches"
	response_harm_simple = "crunch"

	ai_controller = /datum/ai_controller/basic_controller/migrant

/mob/living/basic/migrant/Initialize(mapload)
	. = ..()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_GREEN, COLOR_PURPLE, COLOR_ORANGE)


/// The migrant AI controller
/datum/ai_controller/basic_controller/migrant
	blackboard = list( // Always cowardly
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic, // Use this to find people to run away from
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BASIC_MOB_FLEE_DISTANCE = 1,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk // Random delayed teleportation.
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/plasma_search, // Search for plasma.

		// Skedaddle
		/datum/ai_planning_subtree/flee_target/mouse,
		// Otherwise, look for and execute hunts for cabling
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

// Mouse subtree to hunt down delicious cheese.
/datum/ai_planning_subtree/find_and_hunt_target/plasma_search
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target
	hunt_targets = list(/obj/item/stack/sheet/mineral/plasma)
	hunt_range = 5


