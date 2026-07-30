
/obj/structure/cliff
	name = "rocky cliff"
	desc = "It's a long way, to the top, if you find some rocks that rolled."
	icon = 'icons/obj/fluff/flora/cliffs.dmi'
	icon_state = "cliff"
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR | IGNORE_DENSITY
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW|PASSSTRUCTURE
	max_integrity = 125

/obj/structure/cliff/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/cliff/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir & dir)
		return . || mover.throwing || (mover.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
	return TRUE

/obj/structure/cliff/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(dir != direction)
		return
	animate(leaving, pixel_y = 2, time = 0.1 SECONDS)
	animate(leaving, pixel_y = 0, time = 0.1 SECONDS, delay = 0.1 SECONDS)
	new /obj/effect/temp_visual/dust_cloud_dark (get_turf(direction))

/obj/structure/cliff/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(tool.tool_behaviour == TOOL_MINING)
		if(!do_after(user, 3 SECONDS * tool.toolspeed, target = src))
			return
		qdel(src)

/obj/effect/temp_visual/dust_cloud_dark
	name = "dust"
	desc = "We're all like... ash... in the wind."
	icon_state = "dust_cloud"
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE
	pixel_x = -4
	pixel_z = -4
	base_pixel_z = -4
	base_pixel_x = -4
	duration = 1 SECONDS
