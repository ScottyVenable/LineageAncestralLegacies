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
        show_debug_message("Pop " + pop_identifier_string + " (ID: " + string(id) + ") arrived at commanded point (" + string(travel_point_x) + "," + string(travel_point_y) + "). Attempting to resume previous task or idle.");
        
        speed = 0;                      // Ensure speed is zero
        image_speed = 1.0;              // Reset animation speed to default (idle will handle its own)
        has_arrived = true;             // Set flag indicating arrival at this specific command\'s target
                                        // (This flag should be reset to false when a NEW command is issued)
        
        // scr_pop_resume_previous_or_idle will set the new state (e.g., FORAGING, IDLE, etc.)
        // and handle sprite changes as needed for that new state.
        
        // More robust check for the script's existence
        var _resume_script_index = asset_get_index("scr_pop_resume_previous_or_idle");
        
        if (_resume_script_index != -1 && script_exists(_resume_script_index)) {
            script_execute(_resume_script_index); // Execute the script by its index
        } else {
            show_debug_message("ERROR: scr_pop_resume_previous_or_idle script (asset name: \"scr_pop_resume_previous_or_idle\") not found or does not exist! Index: " + string(_resume_script_index) + ". Pop " + string(id) + " defaulting to IDLE.");
            state = PopState.IDLE; // Fallback if the resume script is missing
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