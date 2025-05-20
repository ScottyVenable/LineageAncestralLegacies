/// scr_formations.gml
///
/// Purpose:
///    Provides a collection of utility functions related to pop formations,
///    including calculating slot positions for various formation types and
///    retrieving user-friendly names for formation enums.
///
/// Metadata:
///    Summary:       Utility functions for pop formation logic and display names.
///    Usage:         Call specific functions from this script as needed.
///                   e.g., var slots = scr_formation_calculate_slots(...);
///                          var name = scr_formation_get_name(...);
///    Tags:          [utility][ai][movement][formation][core_gameplay_system]
///    Version:       1.0 - [Current Date] (Consolidated formation functions)
///    Dependencies:  Formation (enum from scr_constants.gml)

// ============================================================================
// FUNCTION: scr_formation_calculate_slots
// (Previously scr_calculate_formation_slots)
// ============================================================================
/// @function scr_formation_calculate_slots(_target_x, _target_y, _num_selected_pops, _formation_type, _spacing)
/// @description Calculates individual target positions (slots) for a group of selected pops.
/// @param {Real}        _target_x            The X-coordinate of the formation's anchor/center point.
/// @param {Real}        _target_y            The Y-coordinate of the formation's anchor/center point.
/// @param {Real}        _num_selected_pops   The total number of pops to arrange.
/// @param {Formation}   _formation_type      The enum value specifying the formation type.
/// @param {Real}        _spacing             The desired distance between pops in the formation.
/// @returns {Array<Struct>} An array of structs { x: slot_x, y: slot_y }, or an empty array.
function scr_formation_calculate_slots(_target_x, _target_y, _num_selected_pops, _formation_type, _spacing) {
    var _slots = []; 

    if (_num_selected_pops <= 0) {
        return _slots; 
    }
    if (_num_selected_pops == 1) {
        array_push(_slots, { x: _target_x, y: _target_y });
        return _slots;
    }

    switch (_formation_type) {
        case Formation.LINE_HORIZONTAL:
            var _total_width = (_num_selected_pops - 1) * _spacing;
            var _start_x = _target_x - (_total_width / 2);
            for (var i = 0; i < _num_selected_pops; i++) {
                array_push(_slots, { x: _start_x + (i * _spacing), y: _target_y });
            }
            break;

        case Formation.LINE_VERTICAL:
            var _total_height = (_num_selected_pops - 1) * _spacing;
            var _start_y = _target_y - (_total_height / 2);
            for (var i = 0; i < _num_selected_pops; i++) {
                array_push(_slots, { x: _target_x, y: _start_y + (i * _spacing) });
            }
            break;

        case Formation.GRID:
            var _cols = ceil(sqrt(_num_selected_pops));
            var _rows = ceil(_num_selected_pops / _cols);
            var _grid_width = (_cols - 1) * _spacing;
            var _grid_height = (_rows - 1) * _spacing;
            var _start_gx = _target_x - (_grid_width / 2);
            var _start_gy = _target_y - (_grid_height / 2);
            var _pop_index = 0;
            for (var r = 0; r < _rows; r++) {
                for (var c = 0; c < _cols; c++) {
                    if (_pop_index < _num_selected_pops) {
                        array_push(_slots, { x: _start_gx + (c * _spacing), y: _start_gy + (r * _spacing) });
                        _pop_index++;
                    } else { break; }
                }
                if (_pop_index >= _num_selected_pops) break;
            }
            break;

        case Formation.STAGGERED_LINE_HORIZONTAL:
            var _pops_front_row = ceil(_num_selected_pops / 2);
            var _pops_back_row = _num_selected_pops - _pops_front_row;
            var _total_width_front = (_pops_front_row - 1) * _spacing;
            var _start_x_front = _target_x - (_total_width_front / 2);
            var _y_front = _target_y - (_spacing * 0.4); 
            for (var i = 0; i < _pops_front_row; i++) {
                array_push(_slots, { x: _start_x_front + (i * _spacing), y: _y_front });
            }
            if (_pops_back_row > 0) {
                var _total_width_back = (_pops_back_row - 1) * _spacing;
                var _start_x_back = _target_x - (_total_width_back / 2);
                if (_pops_front_row > _pops_back_row) { 
                     _start_x_back = _start_x_front + (_spacing / 2);
                } else if (_pops_back_row > _pops_front_row && _pops_front_row > 0) {
                     _start_x_back = _start_x_front - (_spacing / 2);
                }
                var _y_back = _target_y + (_spacing * 0.4); 
                for (var i = 0; i < _pops_back_row; i++) {
                    array_push(_slots, { x: _start_x_back + (i * _spacing), y: _y_back });
                }
            }
            break;

        case Formation.CIRCLE:
            var _radius = 0;
            if (_num_selected_pops > 1) {
                _radius = (_num_selected_pops * _spacing) / (2 * pi);
            }
            var _min_radius = _spacing * 0.75; 
            _radius = max(_radius, _min_radius); 
            var _angle_step = 360 / _num_selected_pops;
            for (var i = 0; i < _num_selected_pops; i++) {
                var _current_angle = i * _angle_step;
                array_push(_slots, {
                    x: _target_x + lengthdir_x(_radius, _current_angle),
                    y: _target_y + lengthdir_y(_radius, _current_angle)
                });
            }
            break;

        case Formation.NONE:
        default: 
            for (var i = 0; i < _num_selected_pops; i++) {
                array_push(_slots, { x: _target_x, y: _target_y });
            }
            break;
    }
    return _slots;
}


// ============================================================================
// FUNCTION: scr_formation_get_name
// (Previously scr_get_formation_name)
// ============================================================================
/// @function scr_formation_get_name(_formation_enum)
/// @description Returns a user-friendly string representation of a Formation enum value.
/// @param {Formation}   _formation_enum  — The Formation enum value.
/// @returns {String} The name of the formation.
function scr_formation_get_name(_formation_enum) {
    switch (_formation_enum) {
        case Formation.NONE: return "None";
        case Formation.LINE_HORIZONTAL: return "Line Horizontal";
        case Formation.LINE_VERTICAL: return "Line Vertical";
        case Formation.GRID: return "Grid";
        case Formation.STAGGERED_LINE_HORIZONTAL: return "Staggered Line";
        case Formation.CIRCLE: return "Circle";
        default: return "Unknown Formation";
    }
}

// ============================================================================
// SCRIPT INITIALIZATION CONFIRMATION (Optional)
// ============================================================================
// show_debug_message("Script Initialized: scr_formations (Formation Utilities)");