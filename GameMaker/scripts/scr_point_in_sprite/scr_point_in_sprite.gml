/// scr_point_in_sprite.gml
///
/// Purpose:
///   Checks if a given point (x, y) is within the bounding box of an instance\'s sprite.
///   This version considers the instance\'s current `x`, `y`, `sprite_index`, `image_xscale`, and `image_yscale`.
///   It does *not* currently account for `image_angle` (rotation) or precise pixel collision, using the rectangular bounding box instead.
///
/// Metadata:
///   Summary:       Determines if a point is within an instance\'s sprite bounding box.
///   Usage:         Call to check if a mouse click or other point falls on an instance.
///                  e.g., if (scr_point_in_sprite(mouse_x, mouse_y, my_instance)) { /* Clicked on instance */ }
///   Parameters:    _x : real — The x-coordinate of the point to check.
///                  _y : real — The y-coordinate of the point to check.
///                  _target_id : instance_id — The instance whose sprite bounding box will be checked.
///   Returns:       boolean — True if the point is within the sprite\'s bounding box, false otherwise.
///   Tags:          [utility][sprite][collision][input][selection]
///   Version:       1.1 - 2025-05-23 // Added TEMPLATE_SCRIPT structure, clarified bounding box behavior.
///   Dependencies:  None

function scr_point_in_sprite(_x, _y, _target_id) {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // No specific imports or caches needed for this utility.
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    // Check if the target instance exists
    if (!instance_exists(_target_id)) {
        show_debug_message("ERROR: scr_point_in_sprite() — Invalid _target_id: instance does not exist.");
        return false;
    }
    // Ensure the instance has a valid sprite assigned
    if (!sprite_exists(_target_id.sprite_index)) {
        show_debug_message("WARNING: scr_point_in_sprite() — Target instance (" + object_get_name(_target_id.object_index) + ", id: " + string(_target_id) + ") has no valid sprite (sprite_index: " + string(_target_id.sprite_index) + ").");
        return false;
    }
    // Check if point coordinates are real numbers
    if (!is_real(_x) || !is_real(_y)) {
        show_debug_message("ERROR: scr_point_in_sprite() — Invalid coordinates: _x or _y is not a real number.");
        return false;
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // No specific local constants needed for this calculation.
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One-Time Setup / State Variables
    // No specific initialization or state setup needed for this utility.
    #endregion

    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1 Main Behavior / Utility Logic
    // Get the sprite\'s dimensions and the instance\'s scale.
    // Note: sprite_get_width/height return the unscaled dimensions of the sprite asset.
    var _sprite_width = sprite_get_width(_target_id.sprite_index);
    var _sprite_height = sprite_get_height(_target_id.sprite_index);
    
    // Apply the instance\'s scale to the sprite dimensions.
    // abs() is used for scale because a negative scale flips the sprite but doesn\'t change its collision width/height in this context.
    var _scaled_width = _sprite_width * abs(_target_id.image_xscale);
    var _scaled_height = _sprite_height * abs(_target_id.image_yscale);

    // Calculate the sprite\'s bounding box coordinates.
    // This assumes the instance\'s origin (x, y) is at the center of the sprite.
    // If your sprite origins are top-left, these calculations would need adjustment (e.g., _left = _target_id.x; _top = _target_id.y;).
    // GameMaker default origin is top-left, but often centered for character-like objects.
    // For this template, we will assume a centered origin as it is common for collision checks.
    // If your project uses top-left origins for sprites involved in such checks, adjust accordingly.
    // To be more robust, one might use sprite_get_xoffset/yoffset.
    var _origin_x = _target_id.x - (sprite_get_xoffset(_target_id.sprite_index) * abs(_target_id.image_xscale));
    var _origin_y = _target_id.y - (sprite_get_yoffset(_target_id.sprite_index) * abs(_target_id.image_yscale));

    var _left = _origin_x; // Corrected: _target_id.x - _scaled_width / 2;
    var _top = _origin_y;  // Corrected: _target_id.y - _scaled_height / 2;
    var _right = _origin_x + _scaled_width; // Corrected: _target_id.x + _scaled_width / 2;
    var _bottom = _origin_y + _scaled_height; // Corrected: _target_id.y + _scaled_height / 2;

    // Check if the given point (_x, _y) is within the calculated rectangular bounding box.
    // This function is efficient for simple rectangular collision checks.
    // For pixel-perfect collision or rotated sprites, more complex methods would be needed (e.g., involving matrix transformations or collision masks).
    return point_in_rectangle(_x, _y, _left, _top, _right, _bottom);
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return Value
    // The return is handled in the CORE LOGIC section.
    // No specific cleanup needed.
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // Example: For debugging, you could draw the calculated rectangle.
    /*
    if (global.debug_mode) {
        draw_set_color(c_red);
        draw_rectangle(_left, _top, _right, _bottom, true);
    }
    */
    #endregion
}
