/// obj_controller - Event Global Right Released (Mouse_57)
///
/// Purpose:
///     Handles global right-click mouse input.
///     If a "Slot Provider" object (e.g., bush, rock) is clicked (sprite-based detection),
///     selected pops are commanded to find and claim an interaction slot on it.
///     Otherwise, selected pops are commanded to move (potentially in formation).
///
/// Metadata:
///    Summary:        Handles right-click commands for interactions (via slots) or movement.
///    Usage:          obj_controller Event: Mouse > Global Mouse > Global Right Released
///    Parameters:     none
///    Returns:        void
///    Tags:           [input][command][interaction][movement][formation][slot_system]
///    Version:        1.9 - [Current Date] (Corrected scope for _target_object_for_interaction in 'with' block)
///    Dependencies:   obj_pop, par_slot_provider (or objects with slot variables), PopState (enum),
///                     scr_interaction_slot_get_free, scr_interaction_slot_claim,
///                     scr_interaction_slot_get_world_pos, scr_interaction_slot_release,
///                     scr_calculate_formation_slots, global.current_formation_type,
///                     global.formation_spacing, global.order_counter

// =========================================================================
// 0. IMPORTS & CACHES
// =========================================================================
#region 0.1 Imports & Cached Locals
// Functions from scr_interaction will be called directly
#endregion

// =========================================================================
// 1. INITIAL CHECKS & MOUSE POSITION
// =========================================================================
#region 1.1 Setup
var _event_mouse_x_room = device_mouse_x(0); // Mouse X in room coordinates
var _event_mouse_y_room = device_mouse_y(0); // Mouse Y in room coordinates
var _clicked_interactive_object = noone;   // Will store the ID of a clicked slot provider
#endregion

// =========================================================================
// 2. DETECT CLICKED INTERACTIVE OBJECT (SLOT PROVIDER - Sprite Focused)
// =========================================================================
#region 2.1 Detect Slot Provider (Sprite-Focused)
var _potential_targets_list = ds_list_create();
var _num_targets_found = instance_position_list(_event_mouse_x_room, _event_mouse_y_room, par_slot_provider, _potential_targets_list, false);

if (_num_targets_found > 0) {
    for (var i = 0; i < _num_targets_found; i++) {
        var _inst_id = _potential_targets_list[| i];
        if (position_meeting(_event_mouse_x_room, _event_mouse_y_room, _inst_id)) {
            _clicked_interactive_object = _inst_id;
            break; 
        }
    }
}
ds_list_destroy(_potential_targets_list);

if (instance_exists(_clicked_interactive_object)) {
    var _can_interact = true;
    // Example: If it's a bush, check if it's harvestable
    if (object_is_ancestor(_clicked_interactive_object.object_index, obj_redBerryBush)) {
        if (variable_instance_exists(_clicked_interactive_object, "is_harvestable") &&
            !_clicked_interactive_object.is_harvestable) {
            _can_interact = false;
            // show_debug_message("Clicked on a non-harvestable bush.");
        }
    }
    if (!_can_interact) {
        _clicked_interactive_object = noone;
    }
}
#endregion

// =========================================================================
// 3. COMMAND LOGIC
// =========================================================================
#region 3.1 Interaction Command (if an interactive object was clicked)
if (_clicked_interactive_object != noone) {
    // Use _clicked_interactive_object directly, as it's a local var in this event's scope
    var _target_object_for_this_command = _clicked_interactive_object; 
    var _pops_assigned_to_interaction = 0;
    var _successfully_assigned_pops = []; // Keep track of pops successfully assigned in this batch

    with (obj_pop) {
        if (selected) {
            // If this pop was already working on something else, release its old slot
            if ((state == PopState.FORAGING || state == PopState.WORKING) && // Check relevant working states
                instance_exists(target_interaction_object_id) && 
                target_interaction_slot_index != -1) {
                
                // If new target is different, or if it's same target but we want to re-evaluate slot
                if (target_interaction_object_id != _target_object_for_this_command) { // Access local var directly
                    scr_interaction_slot_release(target_interaction_object_id, id);
                    target_interaction_object_id = noone;
                    target_interaction_slot_index = -1;
                    target_interaction_type_tag = "";
                } else {
                    // Clicked same target it's already working on. Release slot to re-evaluate/re-claim.
                    scr_interaction_slot_release(target_interaction_object_id, id); 
                    target_interaction_slot_index = -1; // Mark as having no slot temporarily
                }
            }

            var _slot_index = scr_interaction_slot_get_free(_target_object_for_this_command); // Use local var
            
            if (_slot_index != -1) {
                if (scr_interaction_slot_claim(_target_object_for_this_command, _slot_index, id)) { // Use local var
                    var _slot_details = scr_interaction_slot_get_world_pos(_target_object_for_this_command, _slot_index); // Use local var
                    
                    if (_slot_details != undefined) {
                        target_interaction_object_id = _target_object_for_this_command; // Use local var
                        target_interaction_slot_index = _slot_index;
                        target_interaction_type_tag = _slot_details.type_tag;
                        
                        travel_point_x = _slot_details.x;
                        travel_point_y = _slot_details.y;
                        
                        state = PopState.FORAGING; // TODO: Make this dynamic based on target/tag
                        if (state == PopState.FORAGING) { forage_timer = 0; }
                        
                        has_arrived = false;
                        is_waiting = false;
                        
                        array_push(_successfully_assigned_pops, id);
                        show_debug_message($"Pop {id} assigned to work on {target_interaction_object_id} (slot {_slot_index}, type '{target_interaction_type_tag}') at ({floor(travel_point_x)},{floor(travel_point_y)})");
                    } else {
                        show_debug_message($"Pop {id} could not get slot details for target {_target_object_for_this_command}, slot {_slot_index}.");
                        scr_interaction_slot_release(_target_object_for_this_command, id); // Use local var
                    }
                } else {
                     show_debug_message($"Pop {id} failed to claim slot {_slot_index} on target {_target_object_for_this_command} (already taken?).");
                }
            } else {
                show_debug_message($"Pop {id} wants to work on {_target_object_for_this_command}, but no free slots.");
            }
        }
    }
    _pops_assigned_to_interaction = array_length(_successfully_assigned_pops);

    if (_pops_assigned_to_interaction > 0) {
        exit; // At least one pop was assigned an interaction, skip move command
    }
    // If no pops were assigned (e.g., target was full or invalid), it will fall through to move command.
}
#endregion

#region 3.2 Move Command Logic (Fallback if no interaction target clicked or interaction failed for all)
var _selected_pops_list_for_move = [];
with (obj_pop) {
    if (selected) {
        // If pop was working and is now given a simple move command, release its old interaction slot.
        if ((state == PopState.FORAGING || state == PopState.WORKING) && 
            instance_exists(target_interaction_object_id) && 
            target_interaction_slot_index != -1) {
            scr_interaction_slot_release(target_interaction_object_id, id);
            target_interaction_object_id = noone;
            target_interaction_slot_index = -1;
            target_interaction_type_tag = "";
        }
        array_push(_selected_pops_list_for_move, id);
    }
}
var _num_selected_for_move = array_length(_selected_pops_list_for_move);

if (_num_selected_for_move > 0) {
    global.order_counter++; 

    if (_num_selected_for_move > 1 && global.current_formation_type != Formation.NONE) {
        // --- MULTIPLE POPS & FORMATION SELECTED ---
        var _formation_slots = scr_calculate_formation_slots(
            _event_mouse_x_room, _event_mouse_y_room, _num_selected_for_move,
            global.current_formation_type, global.formation_spacing
        );
        if (array_length(_formation_slots) == _num_selected_for_move) {
            for (var i = 0; i < _num_selected_for_move; i++) {
                var _pop_id = _selected_pops_list_for_move[i]; 
                var _slot = _formation_slots[i]; // This is a position struct {x, y} from formation calc
                if (instance_exists(_pop_id)) { 
                    with (_pop_id) {
                        travel_point_x = _slot.x; 
                        travel_point_y = _slot.y;
                        has_arrived = false; 
                        state = PopState.COMMANDED;
                        order_id = global.order_counter; 
                        is_waiting = false;
                    }
                }
            }
        } else { 
            // Fallback to all move to same spot if formation slot calculation failed (shouldn't happen with current logic)
            show_debug_message("ERROR (Controller GRR): Mismatch in formation slots. Defaulting to single point move for group.");
            for (var i = 0; i < _num_selected_for_move; i++) {
                var _pop_id = _selected_pops_list_for_move[i];
                if (instance_exists(_pop_id)) { 
                    with (_pop_id) {
                        travel_point_x = _event_mouse_x_room; 
                        travel_point_y = _event_mouse_y_room;
                        has_arrived = false; 
                        state = PopState.COMMANDED;
                        order_id = global.order_counter; 
                        is_waiting = false;
                    }
                }
            }
        }
    } else {
        // --- SINGLE POP OR Formation.NONE ---
        for (var i = 0; i < _num_selected_for_move; i++) {
            var _pop_id = _selected_pops_list_for_move[i];
            if (instance_exists(_pop_id)) { 
                with (_pop_id) {
                    travel_point_x = _event_mouse_x_room; 
                    travel_point_y = _event_mouse_y_room;
                    has_arrived = false; 
                    state = PopState.COMMANDED;
                    order_id = global.order_counter; 
                    is_waiting = false;
                }
            }
        }
    }
}
#endregion

// =========================================================================
// 4. CLEANUP & RETURN
// =========================================================================
#region 4.1 Cleanup
// (No dynamic data structures created directly in this event that need explicit cleanup here)
#endregion