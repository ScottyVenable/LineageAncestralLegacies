/// scr_formations
///
/// Purpose:
///   Provides functions to calculate positions for entities based on specified
///   formation types. Used by the spawn system (scr_spawn_system) to arrange
///   groups of spawned instances.
///
/// Metadata:
///   Summary:       Calculates entity positions for various spawn formations.
///   Usage:         Called by scr_spawn_system.world_gen_spawn or other group spawning logic.
///   Parameters:
///     formation_type : FormationType enum - The desired formation.
///     spawn_count    : real             - The number of entities to arrange.
///     center_x       : real             - The central x-coordinate for the formation.
///     center_y       : real             - The central y-coordinate for the formation.
///     options        : struct (optional)- Additional parameters specific to the formation type
///                                         (e.g., radius for CIRCLE/RANDOM_WITHIN_RADIUS,
///                                          spacing for GRID/LINE, columns for GRID).
///   Returns:       Array of structs, where each struct is { x: real, y: real },
///                  representing the calculated positions. Returns an empty array if
///                  spawn_count is 0 or formation_type is invalid.
///   Tags:          [utility][spawn][positioning][formations]
///   Version:       1.1 — 2025-05-25 (Adapted to FormationType, added RANDOM_WITHIN_RADIUS)
///   Dependencies:  FormationType (enum from scr_constants)
///   Created:       (Original creation date before 2025-05-25)
///   Modified:      2025-05-25

// ============================================================================
// FUNCTION: scr_calculate_formation_positions
// ============================================================================
/// @function scr_calculate_formation_positions(formation_type, spawn_count, center_x, center_y, options = {})
/// @description Calculates individual target positions (slots) for a group of entities to be spawned.
/// @param {FormationType} formation_type     The enum value specifying the formation type (from scr_constants).
/// @param {Real}        spawn_count          The total number of entities to arrange.
/// @param {Real}        center_x             The X-coordinate of the formation's anchor/center point.
/// @param {Real}        center_y             The Y-coordinate of the formation's anchor/center point.
/// @param {Struct}      [options]            Optional struct for additional parameters:
///                                             .spacing : Real - Distance between entities (default: 32).
///                                             .radius  : Real - Radius for CIRCLE or RANDOM_WITHIN_RADIUS (default: 64 or scaled by count).
///                                             .columns : Real - Number of columns for GRID (default: sqrt(spawn_count)).
/// @returns {Array<Struct>} An array of structs { x: slot_x, y: slot_y }, or an empty array.
function scr_calculate_formation_positions(formation_type, spawn_count, center_x, center_y, options = {}) {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // (No specific script imports needed for this version, relies on enums and math functions)
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    if (!is_real(spawn_count) || spawn_count <= 0) {
        show_debug_message("WARNING: scr_calculate_formation_positions - spawn_count is zero or invalid. Returning empty array.");
        return [];
    }
    // Default options if not provided
    if (!variable_struct_exists(options, "spacing")) {
        options.spacing = 32; 
        // show_debug_message($"INFO: scr_calculate_formation_positions - No spacing provided, defaulting to {options.spacing}px.");
    }
    if (!variable_struct_exists(options, "radius") && 
        (formation_type == FormationType.CIRCLE || formation_type == FormationType.RANDOM_WITHIN_RADIUS)) {
        options.radius = max(32, spawn_count * 6); // Adjusted default radius logic
        // show_debug_message($"INFO: scr_calculate_formation_positions - No radius for {formation_type}, defaulting to {options.radius}px.");
    }
    if (!variable_struct_exists(options, "columns") && formation_type == FormationType.GRID) {
        options.columns = max(1, floor(sqrt(spawn_count))); 
        // show_debug_message($"INFO: scr_calculate_formation_positions - No columns for GRID, defaulting to {options.columns}.");
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS (Extracted from options)
    // =========================================================================
    #region 2.1 Local Constants
    var _positions_array = [];
    var _spacing = options.spacing;
    // Ensure radius and columns are defined if needed, even if not explicitly set (they get defaults above)
    var _radius = variable_struct_exists(options, "radius") ? options.radius : 0; 
    var _columns = variable_struct_exists(options, "columns") ? options.columns : 1;
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP (Not applicable for this utility)
    // =========================================================================
    // (No state setup needed for this calculation function)
    #endregion

    // =========================================================================
    // 4. CORE LOGIC: Calculate positions based on formation_type
    // =========================================================================
    #region 4.1. Formation Calculation
    switch (formation_type) {
        case FormationType.NONE:
            // All entities at the center point. The spawning system might add jitter if desired.
            for (var i = 0; i < spawn_count; i++) {
                array_push(_positions_array, { x: center_x, y: center_y });
            }
            break;

        case FormationType.GRID:
            var _rows = ceil(spawn_count / _columns);
            var _total_grid_width = (_columns - 1) * _spacing;
            var _total_grid_height = (_rows - 1) * _spacing;
            var _start_x = center_x - _total_grid_width / 2;
            var _start_y = center_y - _total_grid_height / 2;
            var _current_count = 0;
            for (var r = 0; r < _rows; r++) {
                for (var c = 0; c < _columns; c++) {
                    if (_current_count >= spawn_count) break;
                    array_push(_positions_array, { 
                        x: _start_x + c * _spacing, 
                        y: _start_y + r * _spacing 
                    });
                    _current_count++;
                }
                if (_current_count >= spawn_count) break;
            }
            break;

        case FormationType.LINE_HORIZONTAL:
            var _total_width = (spawn_count - 1) * _spacing;
            var _start_x = center_x - _total_width / 2;
            for (var i = 0; i < spawn_count; i++) {
                array_push(_positions_array, { 
                    x: _start_x + i * _spacing, 
                    y: center_y 
                });
            }
            break;

        case FormationType.LINE_VERTICAL:
            var _total_height = (spawn_count - 1) * _spacing;
            var _start_y = center_y - _total_height / 2;
            for (var i = 0; i < spawn_count; i++) {
                array_push(_positions_array, { 
                    x: center_x, 
                    y: _start_y + i * _spacing 
                });
            }
            break;

        case FormationType.CIRCLE:
            if (spawn_count == 1) { // Single entity in the center
                 array_push(_positions_array, { x: center_x, y: center_y });
                 break;
            }
            // Calculate radius if not explicitly provided or if it's too small for the number of entities
            var _calculated_radius = (_spacing * spawn_count) / (2 * pi); // Circumference = spawn_count * spacing
            _radius = max(_radius, _calculated_radius, _spacing / 2); // Ensure radius is at least options.radius, calculated, or half spacing
            
            var _angle_step = 360 / spawn_count;
            for (var i = 0; i < spawn_count; i++) {
                var _angle = i * _angle_step;
                array_push(_positions_array, { 
                    x: center_x + lengthdir_x(_radius, _angle), 
                    y: center_y + lengthdir_y(_radius, _angle) 
                });
            }
            break;

        case FormationType.RANDOM_WITHIN_RADIUS:
            if (_radius <= 0) { // Ensure a positive radius for random placement
                _radius = 32; // Fallback if radius is zero or negative
                show_debug_message($"WARNING: scr_calculate_formation_positions (RANDOM_WITHIN_RADIUS) - Radius was {options.radius}, using fallback {_radius}px.");
            }
            for (var i = 0; i < spawn_count; i++) {
                var _rand_dist = random(_radius); // Distance from center_x, center_y
                var _rand_angle = random(360);    // Angle for the random point
                array_push(_positions_array, { 
                    x: center_x + lengthdir_x(_rand_dist, _rand_angle), 
                    y: center_y + lengthdir_y(_rand_dist, _rand_angle) 
                });
            }
            break;

        default:
            show_debug_message($"ERROR: scr_calculate_formation_positions - Unknown formation_type: {formation_type}. Defaulting to FormationType.NONE behavior.");
            // Fallback to NONE behavior (all at center_x, center_y)
            for (var i = 0; i < spawn_count; i++) {
                array_push(_positions_array, { x: center_x, y: center_y });
            }
            break;
    }
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return
    return _positions_array;
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    // (No specific debug hooks in this version)
}

// Removed scr_formation_get_name as it's not directly part of the positioning logic
// and can be added elsewhere if UI display of formation names is needed.

// ============================================================================
// SCRIPT INITIALIZATION CONFIRMATION (Optional)
// ============================================================================
// show_debug_message("Script Updated: scr_formations (Formation Calculation Utility)");