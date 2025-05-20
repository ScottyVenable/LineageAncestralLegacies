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
        speed = 2.0; // Commanded movement speed (adjust as needed)
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
    #region 2.1 Arrival and Transition to WAITING
    // Check if pop is exactly at the travel point and speed is 0 (meaning snapped or arrived)
    if (x == travel_point_x && y == travel_point_y && speed == 0) {
        // Arrived at the commanded destination
        show_debug_message($"Pop {pop_identifier_string} (ID: {id}) arrived at commanded point ({travel_point_x},{travel_point_y}). Entering WAITING state.");
        
        speed = 0;                      // Ensure speed is zero
        image_speed = 1.0;              // Reset animation speed to default (idle will handle its own)
        has_arrived = true;             // Set flag indicating arrival at this specific command's target
                                        // (This flag should be reset to false when a NEW command is issued)
        
        state = PopState.WAITING;       // <<<<<----- CHANGED: Transition to WAITING state -----<<<<<
        is_waiting = true;              // <<<<<----- ADDED: Set the is_waiting flag -----<<<<<
        
        // Reset state-specific initialization flags
        _commanded_state_initialized = false; 
        // idle_timer = 0; // Reset idle timer if WAITING state uses it or if IDLE is next
                           // Your scr_pop_idle handles idle_timer when state becomes IDLE.
                           // WAITING state typically doesn't progress an idle_timer towards wandering.
    }
    #endregion

    // =========================================================================
    // 3. SEPARATION (Apply every step while moving or waiting at spot)
    // =========================================================================
    #region 3.1 Pop Separation
    scr_separate_pops();
    #endregion
}