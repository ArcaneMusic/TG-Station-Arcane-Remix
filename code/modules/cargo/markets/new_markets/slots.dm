#define CARGO_ORDER_BUY 1
#define CARGO_ORDER_SELL 1

/datum/cargo_slot
	///The visible name used for this cargo slot, for buy or sell orders
	var/name = "whoops!"
	///The visible description to be built for the player to be able to follow.
	var/desc = "Can't show that in a cargo slot!"
	///Iis this cargo_slot a buy or sell order?
	var/buy_or_sell = CARGO_ORDER_BUY
	///What cumulative value does this cargo order have?
	var/credit_value = 0
	///Is this slot being held by the crew? Prevents the credit value from sliding, as well as makes it immune to being rerolled by the subsystem.
	var/being_held = FALSE
	///What cargo items are being held within this order? Buy and sell order items share both a buy and sell value seperately, so it can hold both, with buy_or_sell deciding which way.
	var/list/current_items = list()

/datum/cargo_slot/New()
	. = ..()
	for(var/i in 1 to (rand(2,4)))
		var/datum/supply_pack/current_pack = pick(/datum/supply_pack/materials/plasteel20, /datum/supply_pack/exploration/shrubbery, /datum/supply_pack/security/armor)
		credit_value += current_pack.cost //placeholders, for everything here.
		current_items += current_pack

/datum/cargo_slot/buy
	name = "Buy Order"
	buy_or_sell = CARGO_ORDER_BUY

/datum/cargo_slot/sell
	name = "Sell Order"
	buy_or_sell = CARGO_ORDER_SELL

#undef CARGO_ORDER_BUY
#undef CARGO_ORDER_SELL
