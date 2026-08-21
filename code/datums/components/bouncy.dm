
/datum/component/bouncy
	var/bounces = 0
	var/max_bounces = 2

/datum/component/bouncy/Initialize(max_bounces = 2)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(bounces)
		src.max_bounces = max_bounces

/datum/component/bouncy/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(bounce_missed_throw))
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(return_hit_bounce))

/datum/component/bouncy/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_THROW_LANDED, COMSIG_MOVABLE_IMPACT, COMSIG_ATOM_EXAMINE))

/datum/component/bouncy/proc/bounce_missed_throw(datum/source, datum/thrownthing/throwingdatum, spin)
	SIGNAL_HANDLER
	if(bounces > max_bounces)
		bounces = 0
		return
	var/mob/thrown_by = throwingdatum?.get_thrower()
	var/obj/item/true_parent = parent
	var/bounce_distance = max(round(throwingdatum.dist_travelled / 2), 1) // Half the distance traveled, rounded, with a minimum of 1
	var/bounce_target = get_turf(TURF_FROM_COORDS_LIST(list(throwingdatum.target_turf.x + round(throwingdatum.dist_x / 2), throwingdatum.target_turf.y + round(throwingdatum.dist_y / 2), throwingdatum.target_turf.z)))
	if(!bounce_target || bounce_target == throwingdatum.starting_turf)
		bounces = 0
		return
	if(istype(thrown_by))
		addtimer(CALLBACK(true_parent, TYPE_PROC_REF(/atom/movable, throw_at), bounce_target, bounce_distance, throwingdatum.speed, thrown_by, TRUE), 0.1 SECONDS)
	bounces++

/datum/component/bouncy/proc/return_hit_bounce(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum, caught)
	SIGNAL_HANDLER
	if(caught || bounces > max_bounces)
		bounces = 0
		return
	var/mob/thrown_by = throwingdatum?.get_thrower()
	var/obj/item/true_parent = parent
	var/bounce_distance = max(round(throwingdatum.dist_travelled / 2), 1) // Half the distance traveled, rounded, with a minimum of 1
	var/bounce_target = get_turf(TURF_FROM_COORDS_LIST(list(throwingdatum.target_turf.x - round(throwingdatum.dist_x / 2), throwingdatum.target_turf.y - round(throwingdatum.dist_y / 2), throwingdatum.target_turf.z)))
	if(!bounce_target || bounce_target == throwingdatum.starting_turf)
		bounces = 0
		return
	if(istype(thrown_by))
		addtimer(CALLBACK(true_parent, TYPE_PROC_REF(/atom/movable, throw_at), bounce_target, bounce_distance, throwingdatum.speed, thrown_by, TRUE), 0.1 SECONDS)
	bounces++
