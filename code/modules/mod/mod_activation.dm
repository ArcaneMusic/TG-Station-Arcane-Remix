/obj/item/mod/control/proc/choose_deploy(mob/user)
	if(!LAZYLEN(mod_parts))
		return
	if(isAI(user))
		to_chat(user, "<span class='warning'>You cannot operate this!</span>")
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/i in 1 to length(mod_parts))
		var/obj/item/piece = mod_parts[i]
		display_names["[piece.name] ([i])"] = REF(piece)
		var/image/piece_image = image(icon = piece.icon, icon_state = piece.icon_state)
		items += list("[piece.name] ([i])" = piece_image)
	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locate(part_reference) in mod_parts
	if(!istype(part) || user.incapacitated())
		return
	if(active || activating)
		to_chat(user, "<span class='warning'>ERROR: Suit activated. Deactivate before further action.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	if(part.loc == src)
		deploy(user, part)
	else
		conceal(user, part)

/obj/item/mod/control/proc/deploy(mob/user, part)
	var/obj/item/piece = part
	if(wearer.equip_to_slot_if_possible(piece,piece.slot_flags,0,0,1))
		visible_message("<span class='notice'>[piece] deploy[piece.p_s()] with a mechanical hiss.</span>", \
		"<span class='notice'>[piece] deploy[piece.p_s()] with a mechanical hiss.</span>", \
		"<span class='hear'>You hear a mechanical hiss.</span>")
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE)
		ADD_TRAIT(piece, TRAIT_NODROP, MOD_TRAIT)
	else if(piece.loc != src)
		to_chat(user, "<span class='warning'>ERROR: [piece] [piece.p_are()] already deployed.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
	else
		to_chat(user, "<span class='warning'>ERROR: Bodypart clothed.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)

/obj/item/mod/control/proc/conceal(mob/user, part)
	var/obj/item/piece = part
	REMOVE_TRAIT(piece, TRAIT_NODROP, MOD_TRAIT)
	wearer.transferItemToLoc(piece, src, TRUE)
	visible_message("<span class='notice'>[piece] retract[piece.p_s()] back into [src] with a mechanical hiss.</span>", \
	"<span class='notice'>[piece] retract[piece.p_s()] back into [src] with a mechanical hiss.</span>", \
	"<span class='hear'>You hear a mechanical hiss.</span>")
	playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/mod/control/proc/toggle_activate(mob/user)
	for(var/h in mod_parts)
		var/obj/item/part = h
		if(part.loc == src)
			to_chat(user, "<span class='warning'>ERROR: Not all parts deployed.</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
			return
	var/list/mobs = list()
	mobs += wearer
	if(locked && !active && !allowed(wearer))
		to_chat(user, "<span class='warning'>ERROR: Access level insufficient.</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	if(open)
		to_chat(user, "<span class='warning'>ERROR: Suit panel open. Close before continuing</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	if(activating)
		to_chat(user, "<span class='warning'>ERROR: Suit already [active ? "shutting down" : "staring up"].</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	activating = TRUE
	to_chat(wearer, "<span class='notice'>MODsuit [active ? "shutting down" : "starting up"].</span>")
	if(do_after_mob(wearer,mobs,2 SECONDS,TRUE))
		to_chat(wearer, "<span class='notice'>The [boots.name] [active ? "relax their grip on your legs" : "seal around your feet"].</span>")
		boots.icon_state = "[theme]-boots[active ? "" : "-sealed"]"
		boots.worn_icon_state = "[theme]-boots[active ? "" : "-sealed"]"
		wearer.update_inv_shoes()
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE)
	if(do_after_mob(wearer,mobs,2 SECONDS,TRUE))
		to_chat(wearer, "<span class='notice'>The [gauntlets.name] [active ? "become loose around your fingers" : "tighten around your fingers and wrists"].</span>")
		gauntlets.icon_state = "[theme]-gauntlets[active ? "" : "-sealed"]"
		gauntlets.worn_icon_state = "[theme]-gauntlets[active ? "" : "-sealed"]"
		wearer.update_inv_gloves()
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE)
	if(do_after_mob(wearer,mobs,2 SECONDS,TRUE))
		to_chat(wearer, "<span class='notice'>The [chestplate.name] [active ? "releases your chest" : "cinches tight again your chest"].</span>")
		chestplate.icon_state = "[theme]-chestplate[active ? "" : "-sealed"]"
		chestplate.worn_icon_state = "[theme]-chestplate[active ? "" : "-sealed"]"
		if(active)
			chestplate.clothing_flags &= ~chestplate.visor_flags
		else
			chestplate.clothing_flags |= chestplate.visor_flags
		wearer.update_inv_wear_suit()
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE)
	if(do_after_mob(wearer,mobs,2 SECONDS,TRUE))
		to_chat(wearer, "<span class='notice'>The [helmet.name] hisses [active ? "open" : "closed"].</span>")
		helmet.icon_state = "[theme]-helmet[active ? "" : "-sealed"]"
		helmet.worn_icon_state = "[theme]-helmet[active ? "" : "-sealed"]"
		if(active)
			helmet.flags_cover &= ~helmet.visor_flags_cover
			helmet.flags_inv &= ~helmet.visor_flags_inv
			helmet.clothing_flags &= ~helmet.visor_flags
			helmet.alternate_worn_layer = initial(helmet.alternate_worn_layer)
		else
			helmet.flags_cover |= helmet.visor_flags_cover
			helmet.flags_inv |= helmet.visor_flags_inv
			helmet.clothing_flags |= helmet.visor_flags
			helmet.alternate_worn_layer = null
		wearer.update_inv_head()
		wearer.update_hair()
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE)
	if(do_after_mob(wearer,mobs,2 SECONDS,TRUE))
		to_chat(wearer, "<span class='notice'>Systems [active ? "shut down. Parts unsealed. Goodbye" : "started up. Parts sealed. Welcome"], [wearer.real_name].</span>")
		icon_state = "[theme]-control[active ? "" : "-sealed"]"
		worn_icon_state = "[theme]-control[active ? "" : "-sealed"]"
		wearer.update_inv_back()
		active = !active
		if(active)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = 6000)
			slowdown = slowdown_active
			SEND_SOUND(wearer, sound('sound/mecha/nominal.ogg',volume=50))
			for(var/h in modules)
				var/obj/item/mod/module/thingy = h
				cell_usage += thingy.idle_power_use
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = 6000)
			cell_usage = 0
			slowdown = initial(slowdown)
		wearer.update_equipment_speed_mods()
	activating = FALSE
