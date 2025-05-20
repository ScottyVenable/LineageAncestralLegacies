/// obj_controller - Event Global Right Released (Mouse_57)
///
/// Purpose:
///     Handles global right-click mouse input. If a harvestable bush is clicked,
///     selected pops are commanded to forage from it. Otherwise, selected pops
///     are commanded to move to the clicked location. Includes debug messages
///     for command assignments. Uses device_mouse_x/y for robust mouse coordinate retrieval.
///
/// Metadata:
///     Summary:        Handles right-click commands for pop interactions (forage/move).
///     Usage:          obj_controller Event: Mouse > Global Mouse > Global Right Released
///     Parameters:     none
///     Returns:        void
///     Tags:           [input][command][interaction][foraging][movement][selection][debug]
///     Version:        1.4 - 2025-05-19 (Corrected access to local mouse coordinates for pop commands)
///     Dependencies:   obj_pop, obj_redBerryBush, PopState (enum), global.order_counter,
///                     Standard GML functions (e.g., with, instance_exists, etc.)

// =========================================================================
// 0. IMPORTS & CACHES
// =========================================================================
#region 0.1 Imports & Cached Locals
// (No explicit script imports or complex caching needed for this event's top level)
#endregion

// =========================================================================
// 1. VALIDATION & EARLY RETURNS
// =========================================================================
#region 1.1 Initial Checks & Setup
var b = noone; // Variable to store the ID of a clicked bush

// These are LOCAL variables for this event. They are perfectly fine here.
var _event_mouse_x_room = device_mouse_x(0); // Get mouse X in room coordinates for THIS EVENT
var _event_mouse_y_room = device_mouse_y(0); // Get mouse Y in room coordinates for THIS EVENT
#endregion

// Section 1.2 (Bush Detection & Forage Command) contains an early return if foraging is initiated.

// =========================================================================
// 2. CONFIGURATION & CONSTANTS
// =========================================================================
#region 2.1 Local Constants
// (No specific constants defined at the top level of this event)
#endregion

// =========================================================================
// 3. INITIALIZATION & STATE SETUP (for Move Command)
// =========================================================================
#region 3.1 Order Counter (used if not foraging)
// This is handled directly before the move command logic if that path is taken.
#endregion

// =========================================================================
// 4. CORE LOGIC
// =========================================================================

#region 4.1 Harvestable Bush Detection
// Purpose: Check if the right-click targets a harvestable bush.

with (obj_redBerryBush) {
    var sw = sprite_get_width(sprite_index)  * image_xscale;
    var sh = sprite_get_height(sprite_index) * image_yscale;
    var ox = sprite_get_xoffset(sprite_index) * image_xscale;
    var oy = sprite_get_yoffset(sprite_index) * image_yscale;

    var _left   = x - ox;
    var _top    = y - oy;
    var _right  = _left + sw;
    var _bottom = _top  + sh;

    // Using the event's local mouse coordinates
    if (_event_mouse_x_room >= _left && _event_mouse_x_room <= _right &&
        _event_mouse_y_room >= _top  && _event_mouse_y_room <= _bottom &&
        variable_instance_exists(id, "is_harvestable") && is_harvestable)
    {
        b = id;
        break;
    }
}
#endregion

#region 4.2 Forage Command Logic
// Purpose: If a harvestable bush was clicked, command selected pops to forage.

if (b != noone) {
    with (obj_pop) {
        if (selected) {
            target_bush   = b;
            state         = PopState.FORAGING;
            forage_timer  = 0;
            has_arrived   = false; // Reset arrival for foraging state
            // Ensure `travel_point_x/y` are cleared or set appropriately if Foraging state uses them
            // For now, assuming Foraging state primarily uses target_bush.
            show_debug_message($"DEBUG (obj_controller): Pop ID {id} commanded to FORAGE bush {b}");
        }
    }
    exit; // Skip move command
}
#endregion

#region 4.3 Move Command Logic (Fallback)
// Purpose: If no bush was targeted, issue a move command to selected pops.

global.order_counter++; // Increment the global order counter for this new command

// --- DEBUG: Check mouse coordinates in controller's scope before 'with' block ---
// Using the event's local mouse coordinates
show_debug_message($"DEBUG (obj_controller - Move Command): Event Mouse Coords Before 'with': mouse_x={_event_mouse_x_room}, mouse_y={_event_mouse_y_room}");
if (!is_real(_event_mouse_x_room) || !is_real(_event_mouse_y_room)) {
    show_debug_message($"CRITICAL DEBUG (obj_controller - Move Command): _event_mouse_x_room or _event_mouse_y_room is NOT REAL here! mouse_x: {_event_mouse_x_room}, mouse_y: {_event_mouse_y_room}");
}

with (obj_pop) {
    if (selected) {
        var _old_tx = variable_instance_exists(id, "travel_point_x") ? travel_point_x : "N/A";
        var _old_ty = variable_instance_exists(id, "travel_point_y") ? travel_point_y : "N/A";
        show_debug_message($"DEBUG (obj_controller - Move Command): Pop ID {id} selected. Current travel_point_x={_old_tx}, travel_point_y={_old_ty}");

        // Assign mouse coordinates (from the controller event's local variables) to the pop's travel points.
        // We can directly access _event_mouse_x_room and _event_mouse_y_room here because they are
        // local variables in the scope of the event that is executing this 'with' block.
        // No need for 'other.' to access these specific local variables.
        travel_point_x = _event_mouse_x_room; // <<<< CHANGED THIS LINE
        travel_point_y = _event_mouse_y_room; // <<<< CHANGED THIS LINE
        
        show_debug_message($"DEBUG (obj_controller - Move Command): Pop ID {id} NEW travel_point_x={travel_point_x}, travel_point_y={travel_point_y} (set from controller's event local mouse vars)");

        has_arrived    = false;
        state          = PopState.COMMANDED;
        order_id       = global.order_counter; // Use the updated global.order_counter directly.
                                               // 'other.global.order_counter' would also work but is redundant for global vars.
        
        if (!is_real(travel_point_x) || !is_real(travel_point_y)) {
            show_debug_message($"CRITICAL DEBUG (obj_controller - Move Command): Pop ID {id} travel_point_x or travel_point_y became NOT REAL after assignment!");
        }
    }
}
#endregion

// =========================================================================
// 5. CLEANUP & RETURN
// =========================================================================
#region 5.1 Cleanup
// (No dynamic data structures created at this event's top level that need explicit cleanup here)
#endregion

// =========================================================================
// 6. DEBUG/PROFILING (Optional)
// =================================S========================================
#region 6.1 Debug & Profile Hooks
// Debug messages are integrated directly into the core logic sections.
#endregion