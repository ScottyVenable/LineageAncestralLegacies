/// scr_pop_commanded.gml
///
/// Purpose:
///   Handles the COMMANDED state for an obj_pop instance.
///   The pop moves towards its assigned travel_point_x/y.
///   Upon arrival, it stops, sets its state to WAITING, and sets the is_waiting flag.
///
/// Metadata:
///   Summary:       Move to target, then enter WAITING state.
///   Usage:         Called by scr_pop_behavior when state is EntityState.COMMANDED.
///                  e.g., case EntityState.COMMANDED: scr_pop_commanded(); break;
///   Parameters:    none (operates on the calling 'id' instance of obj_pop)
///   Returns:       void
///   Tags:          [pop_behavior][state][movement][command]
///   Version:       1.1 - [Current Date] (Changed arrival state to WAITING and sets is_waiting flag)
///   Dependencies:  scr_update_walk_sprite, scr_separate_pops, EntityState (enum),
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
        // _commanded_state_initialized: Flag to ensure this setup runs only once per entry into the COMMANDED state.
        // scr_update_walk_sprite(); // Ensure correct walking sprite is set - This is called unconditionally below (line 35)
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
        // If the travel point is invalid (e.g., outside room boundaries or inside a solid object),
        // the pop should revert to a waiting or idle state to prevent errors or getting stuck.
        // Log this event for debugging purposes.
        debug_message($"ERROR (Pop {id} - Commanded): Invalid travel_point ({travel_point_x},{travel_point_y}). Reverting to WAITING.");
        state = EntityState.WAITING; // Use new WAITING state
        is_waiting = true; // Explicitly set to wait
        speed = 0;
        _commanded_state_initialized = false; // Reset for next time
        exit;
    }

    var _dist_to_target = point_distance(x, y, travel_point_x, travel_point_y);

    if (_dist_to_target > 2) { // Threshold for movement (e.g., 2 pixels)
        direction = point_direction(x, y, travel_point_x, travel_point_y);
        // 'stats' is a struct on this instance, typically initialized in the Create event of obj_pop.
        // When commanded, the pop should use its run_speed.
        speed = stats.run_speed; // Commanded movement speed (adjust as needed)
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
        // Pop has arrived at the commanded destination.
        // Log this event for tracking and debugging pop movement and task completion.
        var _pop_id_str = get_pop_identifier_string(id); // Helper to get a consistent name/ID string
        debug_message("Pop " + _pop_id_str + " (ID: " + string(id) + ") arrived at commanded point (" + string(travel_point_x) + "," + string(travel_point_y) + ").");

        // Clear pathfinding variables as the destination is reached
        speed = 0;                      // Ensure speed is zero
        image_speed = 1.0;              // Reset animation speed to default (idle will handle its own)
        has_arrived = true;             // Set flag indicating arrival at this specific command's target
        
        // If there's no specific interaction target associated with this commanded move,
        // the pop should just become idle or wait at the location.
        // We check 'target_object_id' which should be set if the command was to interact with something.
        // If 'target_object_id' is 'noone', it was a simple move-to-point command.
        if (!instance_exists(target_object_id)) { // Or target_object_id == noone, if that's how you designate pure move commands
            // If the command was to an open point (no specific interaction target),
            // the pop should transition to an idle state or resume a previous general task.
            // Log this for clarity on pop behavior.
            debug_message("Pop " + _pop_id_str + ": Command was to an open point. Transitioning to IDLE. No interaction slot needed.");
            state = EntityState.IDLE; // Use new IDLE state
            // is_waiting = true; // if transitioning to WAITING
            previous_state = EntityState.NONE; // Clear previous state as the command is complete.
            
            // Clear any potentially lingering interaction details from a previous task
            target_interaction_object_id = noone;
            target_interaction_slot_index = -1;
            target_interaction_type_tag = "";

        } else {
            // The command was likely to move to an interactive object (target_object_id is set).
            // Now, let scr_pop_resume_previous_or_idle handle if it should interact or resume something else.
            // This path assumes that if target_object_id is set, scr_pop_resume_previous_or_idle
            // might try to interact with it or a previously known target.
            debug_message("Pop " + _pop_id_str + ": Command destination might be interactive or had a previous task. Calling scr_pop_resume_previous_or_idle.");

            var _resume_script_name = "scr_pop_resume_previous_or_idle";
            var _resume_script_asset_index = asset_get_index(_resume_script_name);
            
            if (_resume_script_asset_index != -1 && script_exists(_resume_script_asset_index)) {
                script_execute(_resume_script_asset_index);
            } else {
                // If the resume script itself is not found, this is a critical error.
                // The pop should default to a safe state (Idle) and log the error for debugging.
                // This prevents the game from crashing due to a missing script reference.
                if (!is_undefined(_resume_script_name)) { // only log if a name was actually there
                    debug_message("CRITICAL ERROR (Pop " + _pop_id_str + "): Script '" + _resume_script_name + "' not found! Defaulting to IDLE.");
                }
                change_pop_state(id, PopState.Idle); // Fallback to Idle state
            }
        }
        
        depth = -y; // Update depth based on final position
        _commanded_state_initialized = false; 
    }
    #endregion

    // =========================================================================
    // 3. SEPARATION (Apply every step while moving or waiting at spot)
    // =========================================================================
    #region 3.1 Pop Separation
    scr_separate_pops();
    #endregion
}