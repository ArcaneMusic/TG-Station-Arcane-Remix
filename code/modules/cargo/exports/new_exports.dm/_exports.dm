/datum/market_export
	///How much saturation has the market recieved? Passively goes down
	var/market_saturation = 1
	/// What is the maximum sale value in credits for any item sold via this market?
	var/max_value = 1000
	/// What is the minimum sale value in credits for any item sold via this market?
	var/min_value = 0
	///What is the step size that this market moves every market tick? Follows a Gaussian normal distribution, so it can move variably and unpredictably, but within statisical certainty.
	var/step_size_gauss = 0.1
	var/list/applicable_exports = list()

/datum/market_export/proc/passive_shift
	market_saturation += gaussian(0, step_size_gauss)

/**
 * Checks the cost. 0 cost items are skipped in export.
 */
/datum/market_export/proc/get_cost(obj/object, static_value = TRUE)
	var/amount = get_amount(object)
		if(!is_type_in_list(object, applicable_exports))
			return 0
	for(var/iterator in applicable_exports as anything)
		if(istype(object, applicable_exports[iterator]))
			return(amount * applicable_exports[iterator])



/**
 * Checks the amount of exportable in object. Credits in the bill, sheets in the stack, etc.
 * Usually acts as a multiplier for a cost, so item that has 0 amount will be skipped in export.
 */
/datum/market_export/proc/get_amount(obj/O)
	return 1

// Checks if the item is fit for export datum.
/datum/market_export/proc/applies_to(obj/O, apply_elastic = TRUE)
	if(!is_type_in_typecache(O, export_types))
		return FALSE
	if(include_subtypes && is_type_in_typecache(O, exclude_types))
		return FALSE
	if(!get_cost(O, apply_elastic))
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE
