GLOBAL_LIST_EMPTY(markets)

/datum/stock_market
///
var/name = "Debug Cargo Market (real!)"
///
var/desc = "If you see this, scream at a coder."
///
var/saturation = 1.0
///
var/step_size = 0.1
///
var/classification = "roundstart"

/datum/stock_market/proc/affect_sale_value(datum/export/new_export, quantity, transaction = "sale")
	if(!new_export)
		CRASH("Tried to sell an export, but didn't provide an export to the stock market!")
	if(!quantity || quantity < 0)
		CRASH("Tried to sell an export, but tried to sell 0 of something!")
	saturation_diff = (step_size * quantity)
	if(transaction == "sale")
		saturation = CLAMP(saturation + saturation_diff, step_size, 5)
		return TRUE
	saturation = CLAMP(saturation - saturation_diff, step_size, 5)
	return TRUE

/**
 * Moves saturation up and down variably.
 */
/datum/stock_market/proc/natural_shift()
	saturation = saturation + guassian(0, step_size)
	saturation = CLAMP(saturation, step_size, 5)
	return


