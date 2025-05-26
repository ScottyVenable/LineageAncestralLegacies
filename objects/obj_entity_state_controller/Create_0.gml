/// @description Initializes the global pop state definitions.
/// @function scr_initialize_pop_state_definitions

// This script should be called once at the beginning of the game.

show_debug_message("Initializing Pop EntityState Definitions...");

global.EntityStateDefinitions = ds_map_create();

// Define the structure for each state.
// For now, on_enter_state_script and on_exit_state_script are undefined.
// They can be assigned script indices or functions later.

global.EntityStateDefinitions[? EntityState.IDLE] = {
    name: "IDLE",
    type: "passive",
    display_color: c_gray,
    on_execute_state_script: scr_pop_idle,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined
};

global.EntityStateDefinitions[? EntityState.WANDERING] = {
    name: "WANDERING",
    type: "passive",
    display_color: c_orange,
    on_execute_state_script: scr_pop_wandering,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined,
};

global.EntityStateDefinitions[? EntityState.COMMANDED] = {
    name: "COMMANDED",
    type: "command",
    display_color: c_aqua,
    on_execute_state_script: scr_pop_commanded,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined,
    tags: ["player_controlled"] //Only can be used by entities with a "player_controlled" tag
};

global.EntityStateDefinitions[? EntityState.WAITING] = {
    name: "WAITING",
    type: "command",
    display_color: c_dkgray,
    on_execute_state_script: scr_pop_waiting,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined,
    tags: ["can_wait", "player_controlled"]
};

global.EntityStateDefinitions[? EntityState.FORAGING] = {
    name: "FORAGING",
    type: "command",
    display_color: c_green,
    on_execute_state_script: scr_pop_foraging,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined,
    tags: ["can_forage", "player_controlled"]
};

global.EntityStateDefinitions[? EntityState.HAULING] = {
    name: "HAULING",
    // IMPORTANT: scr_pop_hauling will need to be refactored to not require an argument (target_pop)
    // and instead use 'id' internally, like other state scripts.
    // This will be handled in a subsequent step.
    on_execute_state_script: scr_pop_hauling,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined,
    tags: ["can_haul"]
};

show_debug_message("Pop EntityState Definitions Initialized: " + string(ds_map_size(global.EntityStateDefinitions)) + " states defined.");
