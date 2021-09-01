#define MAXIMUM_FUEL_CAPACITY 4
#define PAPER_FUEL_VALUE 0.05
#define LOG_FUEL_VALUE 1
#define FUEL_BURN_TIMER 150 SECONDS
#define MAXIMUM_BURN_TIMER 300 SECONDS

/obj/structure/fireplace
	name = "fireplace"
	desc = "A large stone brick fireplace."
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "fireplace"
	density = FALSE
	anchored = TRUE
	pixel_x = -16
	resistance_flags = FIRE_PROOF
	/// Is the fireplace currently on fire and lit?
	var/lit = FALSE
	///How many logs are currently burning in the fireplace?
	var/fuel_added = 0

/obj/structure/fireplace/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/fireplace/attackby(obj/item/T, mob/user)
	if(istype(T, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/wood = T
		var/space_remaining = MAXIMUM_FUEL_CAPACITY - fuel_added
		var/space_for_logs = round(space_remaining / LOG_FUEL_VALUE)
		if(space_for_logs < 1)
			to_chat(user, span_warning("You can't fit any more of [T] in [src]!"))
			return
		var/logs_used = min(space_for_logs, wood.amount)
		wood.use(logs_used)
		fuel_added += LOG_FUEL_VALUE
		user.visible_message("<span class='notice'>[user] tosses some \
			wood into [src].</span>", "<span class='notice'>You add \
			some fuel to [src].</span>")
	else if(istype(T, /obj/item/paper_bin))
		if(fuel_added >= MAXIMUM_FUEL_CAPACITY)
			to_chat(user, span_warning("You can't fit any more of [T] in [src]!"))
			return
		var/obj/item/paper_bin/paper_bin = T
		user.visible_message("<span class='notice'>[user] throws [T] into \
			[src].</span>", "<span class='notice'>You add [T] to [src].\
			</span>")
		fuel_added += paper_bin.total_paper * PAPER_FUEL_VALUE
		qdel(paper_bin)
	else if(istype(T, /obj/item/paper))
		if(fuel_added >= MAXIMUM_FUEL_CAPACITY)
			to_chat(user, span_warning("You can't fit any more of [T] in [src]!"))
			return
		user.visible_message("<span class='notice'>[user] throws [T] into \
			[src].</span>", "<span class='notice'>You throw [T] into [src].\
			</span>")
		fuel_added += PAPER_FUEL_VALUE
		qdel(T)
	else if(try_light(T,user))
		return
	else
		. = ..()

/obj/structure/fireplace/update_overlays()
	. = ..()
	if(!lit)
		return
	var/burn_time_remaining = burn_time()

	switch(burn_time_remaining)
		if(0 to 50 SECONDS)
			. += "fireplace_fire0"
		if(50 SECONDS to 100 SECONDS)
			. += "fireplace_fire1"
		if(100 SECONDS to 150 SECONDS)
			. += "fireplace_fire2"
		if(150 SECONDS to 200 SECONDS)
			. += "fireplace_fire3"
		if(200 SECONDS to MAXIMUM_BURN_TIMER)
			. += "fireplace_fire4"
	. += "fireplace_glow"

	switch(burn_time_remaining)
		if(0 to 50 SECONDS)
			set_light(1)
		if(50 SECONDS to 100 SECONDS)
			set_light(2)
		if(100 SECONDS to 150 SECONDS)
			set_light(3)
		if(150 SECONDS to 200 SECONDS)
			set_light(4)
		if(200 SECONDS to MAXIMUM_BURN_TIMER)
			set_light(6)

	playsound(src, 'sound/effects/comfyfire.ogg',50,FALSE, FALSE, TRUE)
	var/turf/T = get_turf(src)
	T.hotspot_expose(700, 2.5)
	update_appearance()
	adjust_light()

/obj/structure/fireplace/extinguish()
	if(lit)
		put_out()
	. = ..()

/obj/structure/fireplace/proc/ignite()
	lit = TRUE
	desc = "A large stone brick fireplace, warm and cozy."
	update_appearance()
	adjust_light()
	loc.visible_message("Ignited. Fuel added is [fuel_added]. Current burn time is [burn_time()]")
	var/adjusted_burn_clock = burn_time()
	addtimer(CALLBACK(src, .proc/upkeep), adjusted_burn_clock)

/obj/structure/fireplace/proc/try_light(obj/item/O, mob/user)
	if(lit)
		to_chat(user, span_warning("It's already lit!"))
		return FALSE
	if(fuel_added <= 0)
		to_chat(user, span_warning("[src] needs some fuel to burn!"))
		return FALSE
	var/msg = O.ignition_effect(src, user)
	if(msg)
		visible_message(msg)
		ignite()
		return TRUE

/obj/structure/fireplace/proc/adjust_light()
	if(!lit)
		set_light(0)
		return

/obj/structure/fireplace/proc/upkeep()
	loc.visible_message("Upkeep start. Fuel added is [fuel_added]. Current burn time is [burn_time()]")
	if(!lit)
		return
	else if(fuel_added >= 0)
		addtimer(CALLBACK(src, .proc/upkeep), burn_time())
		fuel_added = clamp(fuel_added - 1, 0, MAXIMUM_FUEL_CAPACITY)
		if(prob(20))
			loc.visible_message("\The [src] flickers and wanes.")
	else
		put_out() //It has stopped burning and has no fuel left.
		return
	update_appearance()
	adjust_light()

/obj/structure/fireplace/proc/put_out()
	lit = FALSE
	update_appearance()
	adjust_light()
	desc = initial(desc)

/obj/structure/fireplace/proc/burn_time()
	if(fuel_added <= 0)
		return 0 //Just in case something breaks we add a little sanity check here.
	var/burn_timer = FUEL_BURN_TIMER //We want to burn in full increments as often as possible.
	if(fuel_added < 1)
		burn_timer = fuel_added * FUEL_BURN_TIMER
	return burn_timer

