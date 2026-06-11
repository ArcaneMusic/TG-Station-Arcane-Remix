// signals for use by mob spawners
/// called when a spawner spawns a mob
#define COMSIG_SPAWNER_SPAWNED "spawner_spawned"

/// Called when a spawner spawns a mob in a turf peel, but we need to use the default case.
#define COMSIG_SPAWNER_SPAWNED_DEFAULT "spawner_spawned_default"

/// Called when a spawner needs to stop early, like when wave defense needs to be stopped due to node drones dying.
#define COMSIG_SPAWNER_STOPPED "spawner_stopped"

/// called when a ghost clicks a spawner role: (mob/living)
#define COMSIG_GHOSTROLE_SPAWNED "ghostrole_spawned"
