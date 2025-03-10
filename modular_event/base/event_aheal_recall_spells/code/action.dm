/**
 * This datum defines an action that can be used by any mob/living to instantly admin heal themselves.
 * By default it has a 30 second cooldown.
 */
/datum/action/cooldown/aheal
	name = "Fully Heal Self"
	button_icon = 'modular_event/base/event_aheal_recall_spells/icons/button.dmi'
	button_icon_state = "arena_heal"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/aheal/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	button_icon_state = initial(button_icon_state)
	if(!IsAvailable())
		button_icon_state += "_used"
	return ..()

/datum/action/cooldown/aheal/Activate(atom/target)
	var/mob/living/user = owner
	var/area/user_area = get_area(user)
	var/static/arena_areas = typecacheof(/area/centcom/tdome)
	if(is_type_in_typecache(user_area.type, arena_areas))
		to_chat(user, span_boldwarning("You cannot use this ability inside [user_area]!"))
		return FALSE

	// custom lightning bolt for sound
	var/turf/lightning_source = get_step(get_step(user, NORTH), NORTH)
	lightning_source.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(get_turf(user), 'sound/effects/magic/charge.ogg', 50, TRUE)
	if (ishuman(user))
		var/mob/living/carbon/human/human_target = user
		human_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)
	user.revive(ADMIN_HEAL_ALL)

	StartCooldown()

	return TRUE

/datum/action/cooldown/spell/summonitem/arena

/datum/action/cooldown/spell/summonitem/arena/before_cast(atom/cast_on)
	var/mob/living/user = owner
	var/area/user_area = get_area(user)
	var/static/arena_areas = typecacheof(/area/centcom/tdome)
	if(is_type_in_typecache(user_area.type, arena_areas))
		to_chat(user, span_boldwarning("You cannot use this ability inside [user_area]!"))
		return SPELL_CANCEL_CAST
	return ..()
