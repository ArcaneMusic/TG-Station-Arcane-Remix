/datum/action/item_action/rig
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_rig.dmi'
	var/obj/item/rig/control/rig

/datum/action/item_action/rig/New(Target)
	..()
	rig = Target

/datum/action/item_action/rig/deploy
	name = "Deploy RIGsuit"
	desc = "Deploy/Conceal a part of the RIGsuit."
	button_icon_state = "deploy"

/datum/action/item_action/rig/deploy/Trigger()
	if(!LAZYLEN(rig.rig_parts))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/i in 1 to length(rig.rig_parts))
		var/obj/item/piece = rig.rig_parts[i]
		display_names["[piece.name] ([i])"] = REF(piece)
		var/image/piece_image = image(icon = piece.icon, icon_state = piece.icon_state)
		items += list("[piece.name] ([i])" = piece_image)
	var/pick = show_radial_menu(rig.wearer, rig, items, custom_check = FALSE, require_near = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locate(part_reference) in rig.rig_parts
	if(!istype(part) || rig.wearer.incapacitated() || !rig)
		return
	if(rig.active || rig.activating)
		to_chat(rig.wearer, "<span class='warning'>ERROR: Suit activated. Deactivate before further action.</span>")
		playsound(rig, 'sound/machines/scanbuzz.ogg', 25, TRUE)
		return
	if(part.loc == rig)
		rig.deploy(part)
	else
		rig.conceal(part)

/datum/action/item_action/rig/activate
	name = "Activate RIGsuit"
	desc = "Activate/Deactivate the RIGsuit."
	button_icon_state = "activate"

/datum/action/item_action/rig/activate/Trigger()
	rig.toggle_activate()

/datum/action/item_action/rig/panel
	name = "RIGsuit Panel"
	desc = "Open the RIGsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/rig/panel/Trigger()
	rig.ui_interact(usr)
