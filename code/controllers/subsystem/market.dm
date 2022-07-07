SUBSYSTEM_DEF(market)
	name = "Market"
	wait = 2 MINUTES
	init_order = INIT_ORDER_ECONOMY
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/market/fire()
	for(var/datum/stock_market/cargo_market in GLOB.markets)
		cargo_market.natural_shift()
