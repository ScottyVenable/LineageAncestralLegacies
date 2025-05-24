/// scr_update_berry_bush_sprite.gml
///
/// Purpose:
///   Updates the sprite and image_index of a berry bush based on its current berry count
///   to visually represent the depletion of berries.
///
/// Metadata:
///   Summary:       Updates berry bush visuals based on berry count.
///   Usage:         Call this script whenever a berry is picked from a bush.
///                  e.g., scr_update_berry_bush_sprite(id); (called from within the bush instance)
///                     or scr_update_berry_bush_sprite(bush_instance_id); (called from another object)
///   Parameters:    target_bush_id : Id.Instance - The instance ID of the berry bush to update.
///   Returns:       void
///   Tags:          [visuals][resources][environment]
///   Version:       1.0 - 2025-05-23
///   Dependencies:  Assumes the target bush instance has 'current_berry_count' and 'max_berry_count' variables,
///                  and sprite assets named 'spr_redBerryBush_full' and 'spr_bush_empty'.

function scr_update_berry_bush_sprite(target_bush_id) {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // Define sprite names for clarity and easier modification if names change
    var _sprite_full = spr_redBerryBush_full;
    var _sprite_empty = spr_bush_empty;
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    if (!instance_exists(target_bush_id)) {
        show_debug_message("ERROR (scr_update_berry_bush_sprite): Target bush instance " + string(target_bush_id) + " does not exist.");
        return;
    }
    if (!variable_instance_exists(target_bush_id, "current_berry_count")) {
        show_debug_message("ERROR (scr_update_berry_bush_sprite): Target bush " + string(target_bush_id) + " is missing 'current_berry_count' variable.");
        return;
    }
    if (!variable_instance_exists(target_bush_id, "max_berry_count")) {
        show_debug_message("ERROR (scr_update_berry_bush_sprite): Target bush " + string(target_bush_id) + " is missing 'max_berry_count' variable.");
        return;
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // The number of frames in the 'full' sprite that represent berry stages (0 to 6 = 7 stages)
    // This assumes frame 0 is the most full, and frame 6 is nearly empty.
    var _full_sprite_berry_stages = sprite_get_number(_sprite_full); // Should be 7
    #endregion

    // =========================================================================
    // 3. CORE LOGIC
    // =========================================================================
    #region 3.1 Update Sprite and Image Index
    var _current_berries = target_bush_id.current_berry_count;
    var _max_berries = target_bush_id.max_berry_count;

    // Ensure current_berries is not less than 0 or more than max_berries for safety
    _current_berries = clamp(_current_berries, 0, _max_berries);

    if (_current_berries == 0) {
        // If no berries, set to the empty sprite
        target_bush_id.sprite_index = _sprite_empty;
        target_bush_id.image_index = 0; // Empty sprite likely has only one frame
        target_bush_id.image_speed = 0; // Stop animation for static empty sprite
    } else {
        // If there are berries, use the full sprite and calculate the frame
        target_bush_id.sprite_index = _sprite_full;
        
        // Calculate the proportion of berries remaining
        // If _max_berries is 0, this would cause a division by zero, so handle that.
        var _berry_proportion = (_max_berries > 0) ? (_current_berries / _max_berries) : 0;
        
        // Map the proportion to the available frames.
        // We want the fullest frame (0) when proportion is high, and nearly empty frame (6) when proportion is low.
        // So, we subtract the proportion from 1 to invert it for frame selection.
        // Example: 100% berries -> (1 - 1) * (7-1) = 0 * 6 = frame 0
        // Example: ~14% berries (1 berry out of 7 max, if max_berry_count matches stages) -> (1 - 0.14) * 6 = ~0.86 * 6 = ~5.16 -> frame 5
        // The number of frames in _sprite_full is _full_sprite_berry_stages. Frame indices are 0 to _full_sprite_berry_stages - 1.
        var _target_frame = floor((1 - _berry_proportion) * (_full_sprite_berry_stages -1));
        
        // Ensure the target frame is within the valid range of the sprite (0 to 6)
        _target_frame = clamp(_target_frame, 0, _full_sprite_berry_stages - 1);
        
        target_bush_id.image_index = _target_frame;
        target_bush_id.image_speed = 0; // Stop animation, as we're setting a specific frame
    }
    #endregion
}
