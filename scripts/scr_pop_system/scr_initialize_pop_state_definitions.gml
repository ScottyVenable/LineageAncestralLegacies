/// @description Initializes the global pop state definitions.
/// @function scr_initialize_pop_state_definitions

// This script should be called once at the beginning of the game.

show_debug_message("Initializing Pop State Definitions...");

global.PopStateDefinitions = ds_map_create();

// Define the structure for each state.
// For now, on_enter_state_script and on_exit_state_script are undefined.
// They can be assigned script indices or functions later.

global.PopStateDefinitions[? PopState.IDLE] = {
    name: "IDLE",
    on_execute_state_script: scr_pop_idle,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined
};

global.PopStateDefinitions[? PopState.WANDERING] = {
    name: "WANDERING",
    on_execute_state_script: scr_pop_wandering,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined
};

global.PopStateDefinitions[? PopState.COMMANDED] = {
    name: "COMMANDED",
    on_execute_state_script: scr_pop_commanded,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined
};

global.PopStateDefinitions[? PopState.WAITING] = {
    name: "WAITING",
    on_execute_state_script: scr_pop_waiting,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined
};

global.PopStateDefinitions[? PopState.FORAGING] = {
    name: "FORAGING",
    on_execute_state_script: scr_pop_foraging,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined
};

global.PopStateDefinitions[? PopState.HAULING] = {
    name: "HAULING",
    // IMPORTANT: scr_pop_hauling will need to be refactored to not require an argument (target_pop)
    // and instead use 'id' internally, like other state scripts.
    // This will be handled in a subsequent step.
    on_execute_state_script: scr_pop_hauling,
    on_enter_state_script: undefined,
    on_exit_state_script: undefined
};

show_debug_message("Pop State Definitions Initialized: " + string(ds_map_size(global.PopStateDefinitions)) + " states defined.");
