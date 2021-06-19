/obj/item/mod/control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODsuit", name)
		ui.open()

/obj/item/mod/control/ui_data()
	var/data = list()
	data["control"] = name
	data["ui_theme"] = theme.ui_theme
	data["interface_break"] = interface_break
	data["malfunctioning"] = malfunctioning
	data["open"] = open
	data["active"] = active
	data["locked"] = locked
	data["complexity"] = complexity
	data["complexity_max"] = complexity_max
	data["selected_module"] = selected_module?.name
	data["wearer_name"] = wearer ? wearer.get_authentification_name("Unknown") : "No Occupant"
	data["wearer_job"] = wearer ? wearer.get_assignment("Unknown","Unknown",FALSE) : "No Job"
	data["ai"] = ai?.name
	data["cell"] = cell?.name
	data["charge"] = cell ? round(cell.percent(), 1) : 0
	data["helmet"] = helmet?.name
	data["chestplate"] = chestplate?.name
	data["gauntlets"] = gauntlets?.name
	data["boots"] = boots?.name
	data["modules"] = list()
	for(var/obj/item/mod/module/module as anything in modules)
		var/list/module_data = list(
			name = module.name,
			description = module.desc,
			module_type = module.module_type,
			active = module.active,
			idle_power = module.idle_power_cost,
			active_power = module.active_power_cost,
			use_power = module.use_power_cost,
			complexity = module.complexity,
			cooldown_time = module.cooldown_time,
			cooldown = COOLDOWN_TIMELEFT(module, cooldown_timer),
			configurable = module.configurable,
			id = module.tgui_id,
			ref = REF(module)
		)
		data["modules"] += list(module_data)
		data += module.add_ui_data()
	return data

/obj/item/mod/control/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!allowed(usr) && locked)
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("lock")
			locked = !locked
			to_chat(usr, span_notice("The suit has been [locked ? "unlocked" : "locked"]."))
		if("activate")
			toggle_activate(usr)
		if("select")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			module.on_select()
		if("configure")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			module.ui_interact(usr)
	return TRUE
