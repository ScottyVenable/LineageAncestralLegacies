/// scr_pop_resume_previous_or_idle.gml
///
/// Purpose:
///   Called when a pop finishes a temporary state (like COMMANDED move, or after satisfying a need)
///   and needs to decide whether to resume its `previous_state` or default to IDLE/WANDERING.
///   It handles logic for re-evaluating and potentially re-engaging with previous tasks like foraging.
///
/// Metadata:
///   Summary:       Resumes a pop's previous task or defaults to idle/wander.
///   Usage:         Called by other pop behavior scripts (e.g., scr_pop_commanded, scr_pop_satisfy_need)
///                  when a pop completes an overriding action.\ Executed in the context of the pop instance.
///   Parameters:    None (operates on the calling pop instance's variables).
///   Returns:       void (directly modifies the pop's state).
///   Tags:          [pop][ai][state][behavior][core]
///   Version:       1.1 - 2025-05-23 // Updated to full TEMPLATE_SCRIPT structure
///   Dependencies:  EntityState (enum), scr_get_state_name, scr_pop_find_foraging_target, scr_interaction_slot_acquire,
///                  Instance variables: previous_state, last_foraged_target_id, last_foraged_slot_index,
///                                      last_foraged_type_tag, state, target_interaction_object_id, etc.,
///                                      pop_identifier_string (for debug), spr_man_idle.

function scr_pop_resume_previous_or_idle() {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // Cache script functions for slightly better performance if called very frequently.
    var _scr_get_state_name = scr_get_state_name;
    var _scr_pop_find_foraging_target = scr_pop_find_foraging_target;
    var _scr_interaction_slot_acquire = scr_interaction_slot_acquire;
    
    // Cache instance variables if they are accessed multiple times from 'self' or 'id'
    // For this script, direct access is generally fine due to GML's optimization, but this is an option.
    var _pop_id_str = self.pop_identifier_string + " (ID:" + string(self.id) + ")"; // For debug messages
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    // No direct parameters to validate for this script as it operates on the calling instance.
    // However, we can check for essential instance variables if needed, though it might be overkill here.
    // Example: if (!variable_instance_exists(id, "previous_state")) { show_debug_message("ERROR..."); return; }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // No specific local constants needed for this logic.
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One-Time Setup / State Variables
    // Debug: Log entry into this script
    show_debug_message("Pop " + _pop_id_str + " executing scr_pop_resume_previous_or_idle. Previous state: " + _scr_get_state_name(self.previous_state));
    #endregion

    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1 Main Behavior / Utility Logic
    // --- Attempt to Resume Previous State ---
    switch (self.previous_state) {
        case EntityState.FORAGING:
            show_debug_message("Pop " + _pop_id_str + " attempting to resume FORAGING.");
            // Try to resume foraging the last target if it's still valid and has resources
            if (instance_exists(self.last_foraged_target_id) &&
                variable_instance_exists(self.last_foraged_target_id, "is_harvestable") &&
                self.last_foraged_target_id.is_harvestable &&
                variable_instance_exists(self.last_foraged_target_id, "resource_count") &&
                self.last_foraged_target_id.resource_count > 0 &&
                self.last_foraged_slot_index != -1) { // Also ensure we had a specific slot

                show_debug_message("Pop " + _pop_id_str + " last_foraged_target_id " + string(self.last_foraged_target_id) + " seems valid. Attempting to reacquire slot " + string(self.last_foraged_slot_index));

                // --- NEW SYSTEM: Try to reacquire the same interaction point ---
                var _point_id = scr_interaction_slot_get_by_pop(self.last_foraged_target_id, self.id);
                var _slot_acquired = false;
                if (_point_id != noone) {
                    _slot_acquired = scr_interaction_slot_claim(_point_id, self.id);
                }
                if (_slot_acquired) {
                    self.target_interaction_object_id = self.last_foraged_target_id;
                    self.target_interaction_slot_index = self.last_foraged_slot_index;
                    self.target_interaction_type_tag = self.last_foraged_type_tag;
                    self.state = EntityState.FORAGING;
                    self.has_arrived = false;
                    self.forage_timer = 0;
                    show_debug_message("Pop " + _pop_id_str + " re-acquired previous interaction point " + string(self.target_interaction_slot_index) + " at " + string(self.target_interaction_object_id) + ". Resuming FORAGING.");
                    self.previous_state = EntityState.NONE;
                    exit;
                } else {
                    // Could not re-acquire the exact same slot, try any available slot on the same target
                    show_debug_message("Pop " + _pop_id_str + " could not re-acquire specific interaction point. Trying any available point on " + string(self.last_foraged_target_id));
                    var _free_point_id = scr_interaction_slot_get_free(self.last_foraged_target_id, self.last_foraged_type_tag);
                    if (_free_point_id != noone && scr_interaction_slot_claim(_free_point_id, self.id)) {
                        // Find the slot index for this point (for legacy compatibility)
                        var _slot_index = -1;
                        var _points = self.last_foraged_target_id.interaction_slots_pop_ids;
                        for (var i = 0; i < array_length(_points); i++) {
                            if (_points[i] == _free_point_id) { _slot_index = i; break; }
                        }
                        self.target_interaction_object_id = self.last_foraged_target_id;
                        self.target_interaction_slot_index = _slot_index;
                        self.target_interaction_type_tag = self.last_foraged_type_tag;
                        self.state = EntityState.FORAGING;
                        self.has_arrived = false;
                        self.forage_timer = 0;
                        show_debug_message("Pop " + _pop_id_str + " acquired new interaction point " + string(_slot_index) + " at " + string(self.target_interaction_object_id) + ". Resuming FORAGING.");
                        self.previous_state = EntityState.NONE;
                        exit;
                    }
                }
            } else {
                 show_debug_message("Pop " + _pop_id_str + " previous forage target " + string(self.last_foraged_target_id) + " is no longer valid, depleted, or no slot info. Will search for new target.");
                 // Fall through to find a new target of the same type
            }

            // If previous target was invalid, or couldn't get a slot, or if last_foraged_target_id was 'noone' (e.g. after depletion without items)
            // Try to find a *new* foraging target, potentially using last_foraged_type_tag if available, or any forageable.
            var _search_tag = (self.last_foraged_type_tag != "" && self.last_foraged_type_tag != undefined) ? self.last_foraged_type_tag : "forage"; // Generalize if specific tag is gone
            var _target_obj_asset = (instance_exists(self.last_foraged_target_id)) ? self.last_foraged_target_id.object_index : obj_redBerryBush; // Default or last known type
            // TODO: This ^ object_index might not be ideal if last_foraged_target_id is noone. Need a better way to determine what object type to search for.
            // For now, defaulting to obj_redBerryBush if last target is gone.
            if (!instance_exists(self.last_foraged_target_id)) _target_obj_asset = obj_redBerryBush; 

            show_debug_message("Pop " + _pop_id_str + " searching for new target of type related to '" + _search_tag + "', considering object asset: " + object_get_name(_target_obj_asset));
            var _found_target_info = _scr_pop_find_foraging_target(self.id, _search_tag, _target_obj_asset);

            if (_found_target_info != undefined && instance_exists(_found_target_info.target_id)) {
                // Attempt to acquire a slot at the new target
                var _new_slot_details = _scr_interaction_slot_acquire(_found_target_info.target_id, self.id, -1, _search_tag); // Pass search_tag to slot acquisition
                if (_new_slot_details != undefined) {
                    self.target_interaction_object_id = _found_target_info.target_id;
                    self.target_interaction_slot_index = _new_slot_details.slot_index;
                    self.target_interaction_type_tag = _new_slot_details.type_tag; // Use the tag from the acquired slot
                    
                    self.state = EntityState.FORAGING;
                    self.has_arrived = false;
                    self.forage_timer = 0;
                    
                    show_debug_message("Pop " + _pop_id_str + " found and acquired slot at NEW foraging target: " + string(self.target_interaction_object_id) + " slot " + string(self.target_interaction_slot_index) + ". Resuming FORAGING.");
                    self.previous_state = EntityState.NONE;
                    // Clear last_foraged_... variables since we are starting fresh with a new target
                    self.last_foraged_target_id = noone;
                    self.last_foraged_slot_index = -1;
                    self.last_foraged_type_tag = "";
                    exit;
                } else {
                    show_debug_message("Pop " + _pop_id_str + " found new target " + string(_found_target_info.target_id) + " but could not acquire slot for tag '" + _search_tag + "'.");
                    // Fall through to default behavior if no slot acquired
                }
            } else {
                show_debug_message("Pop " + _pop_id_str + " could not find any new foraging target for tag '" + _search_tag + "' of type " + object_get_name(_target_obj_asset) + ".");
                // Fall through to default behavior if no new target found
            }
            break;

        // case EntityState.CONSTRUCTION:
        //     // TODO: Implement logic to resume construction
        //     // This would involve checking `last_construction_target_id`, etc.
        //     show_debug_message("Pop " + _pop_id_str + " previous state was CONSTRUCTION. Resume logic not yet implemented.");
        //     break;

        // case EntityState.HAULING:
        //     // Typically, hauling completes and then might call this.
        //     // If a pop was hauling, then got commanded, then finishes command, should it re-evaluate hauling?
        //     // For now, if previous was hauling, it likely means it was interrupted mid-haul.
        //     // Let's try to re-trigger hauling state. scr_pop_hauling will check if still necessary.
        //     show_debug_message("Pop " + _pop_id_str + " previous state was HAULING. Attempting to re-enter HAULING state.");
        //     self.state = EntityState.HAULING;
        //     // self._hauling_state_initialized = false; // If scr_pop_hauling uses an init flag
        //     self.previous_state = EntityState.NONE;
        //     exit;
        //     break;
            
        case EntityState.NONE: // No specific previous state to resume
        case EntityState.IDLE:
        case EntityState.WANDERING:
        case EntityState.COMMANDED: // If previous was commanded, it means the command finished.
        case EntityState.WAITING:   // If previous was waiting, it means it was interrupted while waiting.
            show_debug_message("Pop " + _pop_id_str + " previous state (" + _scr_get_state_name(self.previous_state) + ") does not require specific resume action or is a default state. Will proceed to IDLE/WANDER.");
            break;
            
        default:
            show_debug_message("Pop " + _pop_id_str + " previous state " + _scr_get_state_name(self.previous_state) + " has no resume logic. Defaulting.");
            break;
    }

    // --- Default to IDLE then WANDER if no specific task was resumed ---
    // This section is reached if the switch statement doesn't 'exit'
    
    show_debug_message("Pop " + _pop_id_str + " did not resume a specific task. Transitioning to IDLE.");
    
    // Clear any lingering interaction targets if we are defaulting to idle.
    // This is important because if we were trying to resume foraging but failed,
    // these variables might still be set from the failed attempt.
    self.target_interaction_object_id = noone;
    self.target_interaction_slot_index = -1;
    self.target_interaction_type_tag = "";
    
    // Also clear last_foraged_... to prevent stale data influencing future decisions if we idle now.
    self.last_foraged_target_id = noone;
    self.last_foraged_slot_index = -1;
    self.last_foraged_type_tag = "";

    self.state = EntityState.IDLE; // Default to IDLE using new enum
    self.is_waiting = false; // Not truly waiting for a specific event, just idling
    self.has_arrived = true; // Considered "arrived" at its current idle spot
    self.idle_timer = 0;     // Reset idle timer (defined in obj_pop Create or a constants script)
    // self.wander_timer will be handled by scr_pop_idle
    
    // Ensure sprite is appropriate for idling
    // LEARNING POINT: Using `self` explicitly can improve clarity when instance variables are being modified,
    // especially in scripts that could potentially be called by different contexts (though this one is pop-specific).
    self.sprite_index = spr_pop_man_idle; // Or a generic idle sprite
    self.image_speed = 0.2 + random(0.1); // Slow, slightly varied idle animation
    self.speed = 0;
    
    self.previous_state = EntityState.NONE; // Clear previous state using new enum

    // The scr_pop_idle script will eventually transition to WANDERING if the pop remains idle for too long.
    // No need to explicitly set WANDERING here unless that's the immediate desired behavior.
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return Value
    // This script modifies the pop's state directly and does not return a value.
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // No specific debug/profiling hooks in this version.
    #endregion
}
