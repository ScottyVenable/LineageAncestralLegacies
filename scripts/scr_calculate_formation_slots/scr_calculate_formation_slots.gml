/// scr_calculate_formation_slots.gml
///
/// Purpose:
///    Calculates individual target positions (slots) for a group of selected pops
///    based on a central target point, the number of pops, the desired formation type,
///    and spacing between them.
///
/// Metadata:
///    Summary:       Returns an array of {x, y} structs for formation slots.
///    Usage:         Called by obj_controller when issuing a multi-pop move command.
///                   e.g., var slots = scr_calculate_formation_slots(mx, my, selected_list, global.current_formation_type, global.formation_spacing);
///    Parameters:
///      target_x          : real        — The X-coordinate of the formation's anchor/center point.
///      target_y          : real        — The Y-coordinate of the formation's anchor/center point.
///      num_selected_pops : real        — The total number of pops to arrange.
///      formation_type    : Formation   — The enum value specifying the formation type (e.g., Formation.LINE_HORIZONTAL).
///      spacing           : real        — The desired distance between pops in the formation.
///
///    Returns:       Array<Struct> — An array of structs, each { x: slot_x, y: slot_y }.
///                                   The length of the array will match num_selected_pops.
///                                   Returns an empty array if num_selected_pops is 0 or invalid formation.
///    Tags:          [ai][movement][formation][utility][rts]
///    Version:       1.0 - [Current Date]
///    Dependencies:  Formation (enum from scr_constants.gml)

function scr_calculate_formation_slots(_target_x, _target_y, _num_selected_pops, _formation_type, _spacing) {
    var _slots = []; // Array to store the {x,y} structs for each slot

    if (_num_selected_pops <= 0) {
        return _slots; // Return empty array if no pops
    }

    // If only one pop, its slot is the target itself (though controller might handle this before calling)
    if (_num_selected_pops == 1) {
        array_push(_slots, { x: _target_x, y: _target_y });
        return _slots;
    }

    switch (_formation_type) {
        // ===================================
        case Formation.LINE_HORIZONTAL:
        // ===================================
            var _total_width = (_num_selected_pops - 1) * _spacing;
            var _start_x = _target_x - (_total_width / 2);
            for (var i = 0; i < _num_selected_pops; i++) {
                array_push(_slots, {
                    x: _start_x + (i * _spacing),
                    y: _target_y
                });
            }
            break;

        // ===================================
        case Formation.LINE_VERTICAL:
        // ===================================
            var _total_height = (_num_selected_pops - 1) * _spacing;
            var _start_y = _target_y - (_total_height / 2);
            for (var i = 0; i < _num_selected_pops; i++) {
                array_push(_slots, {
                    x: _target_x,
                    y: _start_y + (i * _spacing)
                });
            }
            break;

        // ===================================
        case Formation.GRID:
        // ===================================
            // Simple grid, tries to be as square as possible
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
                        array_push(_slots, {
                            x: _start_gx + (c * _spacing),
                            y: _start_gy + (r * _spacing)
                        });
                        _pop_index++;
                    } else {
                        break; // Filled all pops
                    }
                }
                if (_pop_index >= _num_selected_pops) break;
            }
            break;

        // ===================================
        case Formation.NONE:
        default: // Fallback to NONE behavior
        // ===================================
            for (var i = 0; i < _num_selected_pops; i++) {
                // All target the same spot
                array_push(_slots, { x: _target_x, y: _target_y });
            }
            break;
    }

    return _slots;
}