/// Unit test that checks if a boulder can be processed by a smelter and refinery.
/datum/unit_test/boulder

/datum/unit_test/boulder/Run()

	var/obj/item/boulder/shabby/arcane = allocate(/obj/item/boulder/shabby)
	var/obj/machinery/bouldertech/refinery/refine = allocate(/obj/machinery/bouldertech/refinery)
	var/obj/machinery/bouldertech/smelter/melt = allocate(/obj/machinery/bouldertech/refinery/smelter)

	//refinery tests
	refine.accept_boulder(arcane)
	TEST_ASSERT(refine.accept_boulder(arcane) == TRUE, "A basic boulder failed to be accepted into the refinery!")
	TEST_ASSERT(refine.breakdown_boulder(arcane) == TRUE, "A basic boulder failed or refused to be broken down by the refinery!")

	//smelter tests
	TEST_ASSERT(melt.accept_boulder(arcane) == TRUE, "A basic boulder failed to be accepted into the smelter!")
	TEST_ASSERT(melt.breakdown_boulder(arcane) == TRUE, "A basic boulder failed or refused to be broken down by the smelter!")
