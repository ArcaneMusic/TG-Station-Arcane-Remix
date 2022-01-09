#define BOOMERANG_REBOUND_INTERVAL (1 SECONDS)
/**
 * If an ojvect is given the boomerang component, it should be thrown back to the thrower after either hitting it's target, or landing on the thrown tile.
 * Thrown objects should
 */
/datum/component/boomerang
	///How far should the boomerang try to travel to return to the thrower?
	var/boomerang_throw_range = 3
	///"Thrownthing" datum for the most recent throw.
	var/datum/thrownthing/thrown_boomerang
	///If this boomerang is thrown, does it re-enable the throwers throw mode?
	var/thrower_easy_catch_enabled = FALSE
	///The object the component's being applied to.
	var/obj/item/true_parent
	COOLDOWN_DECLARE(last_boomerang_throw)

/datum/component/boomerang/Initialize(_boomerang_throw_range, _thrower_easy_catch_enabled)
	. = ..()
	if(!isitem(parent)) //Only items support being thrown around like a boomerang, feel free to make this apply to humans later on.
		return COMPONENT_INCOMPATIBLE
	true_parent = parent

	//Assignments
	if(_boomerang_throw_range)
		boomerang_throw_range = _boomerang_throw_range
	if(_thrower_easy_catch_enabled)
		thrower_easy_catch_enabled = _thrower_easy_catch_enabled

/datum/component/boomerang/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_POST_THROW, .proc/PrepareThrow) ///Collect data on current thrower and the throwing datum
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, .proc/ReturnMissedThrow)
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, .proc/ReturnHitThrow)
	//RegisterSignal(parent, COMSIG_CARBON_SUCCESSFUL_CATCH, .proc/BoomerangCooldown)

/datum/component/boomerang/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_THROW_LANDED, COMSIG_MOVABLE_IMPACT))

/datum/component/boomerang/proc/PrepareThrow(datum/source, atom/thrown_thing, spin)
	SIGNAL_HANDLER
	thrown_boomerang = thrown_thing //Here we update our "thrownthing" datum with that of the original throw for each boomerang. We save it for the return throw.
	if(thrower_easy_catch_enabled && thrown_boomerang?.thrower)
		if(iscarbon(thrown_boomerang.thrower))
			var/mob/living/carbon/Carbon = thrown_boomerang.thrower
			Carbon.throw_mode_on(THROW_MODE_TOGGLE)
	return

/datum/component/boomerang/proc/ReturnHitThrow(datum/source, atom/hit_atom, datum/thrownthing/init_throwing_datum)
	SIGNAL_HANDLER
	if (!COOLDOWN_FINISHED(src, last_boomerang_throw))
		return
	var/caught = hit_atom.hitby(true_parent, FALSE, FALSE, throwingdatum=init_throwing_datum)
	var/mob/thrown_by = true_parent.thrownby?.resolve()
	true_parent.visible_message(span_danger("[true_parent] has been ReturnHitThrow!"))
	AerodynamicSwing(init_throwing_datum)
	if(thrown_by && !caught)
		addtimer(CALLBACK(true_parent, /atom/movable.proc/throw_at, thrown_by, boomerang_throw_range, init_throwing_datum.speed, null, TRUE), 1)
		COOLDOWN_START(src, last_boomerang_throw, BOOMERANG_REBOUND_INTERVAL)
	return

/datum/component/boomerang/proc/ReturnMissedThrow(datum/source, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER
	if (!COOLDOWN_FINISHED(src, last_boomerang_throw))
		return
	var/mob/thrown_by = true_parent.thrownby?.resolve()
	true_parent.visible_message(span_danger("[true_parent] has been ReturnMissedThrow!"))
	AerodynamicSwing(throwing_datum)
	if(thrown_by)
		addtimer(CALLBACK(true_parent, /atom/movable.proc/throw_at, thrown_by, boomerang_throw_range, throwing_datum.speed, null, TRUE), 1)
		COOLDOWN_START(src, last_boomerang_throw, BOOMERANG_REBOUND_INTERVAL)
	return

/datum/component/boomerang/proc/AerodynamicSwing(datum/thrownthing/throwing_datum)
	true_parent.visible_message(span_danger("[true_parent] is flying back at [throwing_datum.thrower]!"), \
						span_danger("You see [true_parent] fly back at you!"), \
						span_hear("You hear an aerodynamic woosh!"))
