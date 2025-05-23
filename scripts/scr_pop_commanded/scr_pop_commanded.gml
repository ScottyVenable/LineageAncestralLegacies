/// scr_pop_commanded.gml
///
/// Purpose:
///   Handles the COMMANDED state for an obj_pop instance.
///   The pop moves towards its assigned travel_point_x/y.
///   Upon arrival, it stops, sets its state to WAITING, and sets the is_waiting flag.
///
/// Metadata:
///   Summary:       Move to target, then enter WAITING state.
///   Usage:         Called by scr_pop_behavior when state is PopState.COMMANDED.
///                  e.g., case PopState.COMMANDED: scr_pop_commanded(); break;
///   Parameters:    none (operates on the calling 'id' instance of obj_pop)
///   Returns:       void
///   Tags:          [pop_behavior][state][movement][command]
///   Version:       1.1 - [Current Date] (Changed arrival state to WAITING and sets is_waiting flag)
///   Dependencies:  scr_update_walk_sprite, scr_separate_pops, PopState (enum),
///                  Instance variables: x, y, travel_point_x, travel_point_y, speed,
///                  direction, image_speed, has_arrived, is_waiting.

function scr_pop_commanded() {
    // =========================================================================
    // 0. INITIALIZATION & ANIMATION (On first effective frame of COMMANDED)
    // =========================================================================
    #region 0.1 Setup on State Entry
    // This logic could also be placed where state is set to COMMANDED,
    // but checking has_arrived (if it means "has arrived at previous target") can work.
    // Assuming 'has_arrived' is false when a new command is given.
    if (!variable_instance_exists(id, "_commanded_state_initialized") || !_commanded_state_initialized) {
        // scr_update_walk_sprite(); // Ensure correct walking sprite is set
        image_speed = 1.5;          // Example: Faster walk animation for commanded move
                                    // Adjust image_speed based on your sprite's animation.
                                    // If scr_update_walk_sprite handles image_speed, this might be redundant or conflict.
        _commanded_state_initialized = true;
    }
    
	// Call scr_update_walk_sprite every step to handle direction changes for animation
	scr_update_walk_sprite();
	#endregion
	

	
	



    // =========================================================================
    // 1. MOVEMENT LOGIC
    // =========================================================================
    #region 1.1 Face and Move Towards Target
    // Ensure travel_point_x and travel_point_y are valid before using them
    if (!is_real(travel_point_x) || !is_real(travel_point_y)) {
        show_debug_message($"ERROR (Pop {id} - Commanded): Invalid travel_point ({travel_point_x},{travel_point_y}). Reverting to WAITING.");
        state = PopState.WAITING;
        is_waiting = true; // Explicitly set to wait
        speed = 0;
        _commanded_state_initialized = false; // Reset for next time
        exit;
    }

    var _dist_to_target = point_distance(x, y, travel_point_x, travel_point_y);

    if (_dist_to_target > 2) { // Threshold for movement (e.g., 2 pixels)
        direction = point_direction(x, y, travel_point_x, travel_point_y);
        speed = pop.base_speed * 2; // Commanded movement speed (adjust as needed)
        // scr_update_walk_sprite(); // Called above already
    } else {
        // Close enough to snap to target
        x = travel_point_x;
        y = travel_point_y;
        speed = 0;
    }
    #endregion

    // =========================================================================
    // 2. ARRIVAL CHECK & STATE TRANSITION
    // =========================================================================
    #region 2.1 Arrival and Transition
    // Check if pop is exactly at the travel point and speed is 0 (meaning snapped or arrived)
    if (x == travel_point_x && y == travel_point_y && speed == 0) {
        // Arrived at the commanded destination
        var _pop_id_str = pop_identifier_string; // Assuming pop_identifier_string is available
        show_debug_message("Pop " + _pop_id_str + " (ID: " + string(id) + ") arrived at commanded point (" + string(travel_point_x) + "," + string(travel_point_y) + "). Attempting to resume or idle.");
        
        speed = 0;                      // Ensure speed is zero
        image_speed = 1.0;              // Reset animation speed to default (idle will handle its own)
        has_arrived = true;             // Set flag indicating arrival at this specific command's target
        
        // --- Call scr_pop_resume_previous_or_idle ---
        // LEARNING POINT: To call a script dynamically, first get its asset index,
        // then check if it exists, then execute it.
        show_debug_message("Pop " + _pop_id_str + ": Preparing to call scr_pop_resume_previous_or_idle.");
        var _resume_script_name = "scr_pop_resume_previous_or_idle";
        var _resume_script_asset_index = asset_get_index(_resume_script_name);
        
        show_debug_message("Pop " + _pop_id_str + ": Asset index for '" + _resume_script_name + "' is " + string(_resume_script_asset_index) + ".");

        if (_resume_script_asset_index != -1 && script_exists(_resume_script_asset_index)) {
            show_debug_message("Pop " + _pop_id_str + ": Script '" + _resume_script_name + "' exists. Executing now.");
            script_execute(_resume_script_asset_index); // Execute the script by its asset index
            show_debug_message("Pop " + _pop_id_str + ": Finished executing '" + _resume_script_name + "'.");
        } else {
            // Fallback if the script is somehow missing
            show_debug_message("CRITICAL ERROR (Pop " + _pop_id_str + "): Script '" + _resume_script_name + "' (Index: " + string(_resume_script_asset_index) + ") not found or does not exist! Defaulting to IDLE state.");
            state = PopState.IDLE;
            // Reset relevant variables for IDLE state if necessary
            target_object_id = noone;
            target_interaction_object_id = noone;
            target_interaction_slot_index = -1;
            // Add any other necessary resets for a clean IDLE state
        }
		
		depth = -y; // Update depth based on final position
        
        // Reset state-specific initialization flags
        _commanded_state_initialized = false; 
        // idle_timer = 0; // Reset by individual states as needed.
    }
    #endregion

    // =========================================================================
    // 3. SEPARATION (Apply every step while moving or waiting at spot)
    // =========================================================================
    #region 3.1 Pop Separation
    scr_separate_pops();
    #endregion
}