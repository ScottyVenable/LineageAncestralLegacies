/// scr_point_in_sprite.gml
///
/// Purpose:
///   Checks if a given point (x, y) is within a specified radius around an instance's origin.
///   This is useful for proximity checks rather than precise pixel-perfect sprite collision.
///
/// Metadata:
///   Summary:       Determines if a point is within a circular area around an instance.
///   Usage:         Call to check if a click or another point is near an instance.
///                  e.g., if (scr_point_in_sprite(mouse_x, mouse_y, my_instance, 50)) { ... }
///   Parameters:    _x : real — The x-coordinate of the point to check.
///                  _y : real — The y-coordinate of the point to check.
///                  _id : instance — The instance whose proximity is being checked.
///                  _radius : real (optional) — The radius of the circular area around the instance's origin.
///                                            Defaults to 50 pixels if not provided.
///   Returns:       boolean — True if the point (_x, _y) is within _radius of _id.x, _id.y; false otherwise.
///   Tags:          [utility][collision][proximity][point][circle]
///   Version:       1.1 - 2025-05-23 // Aligned with TEMPLATE_SCRIPT, clarified purpose.
///   Dependencies:  None
///   Creator:       GameDev AI (Originally) / Your Name // Please update creator if known
///   Created:       2025-05-22 // Assumed creation date, please update if known
///   Last Modified: 2025-05-23 by Copilot // Updated to match template and clarify logic

function scr_point_in_sprite(_x, _y, _id, _radius = 50) { // Default radius set to 50 as per original intent
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
    // Check if _id is a valid instance.
    if (!instance_exists(_id)) {
        show_debug_message("ERROR: scr_point_in_sprite() — Invalid _id parameter: instance does not exist.");
        return false;
    }
    // Check if _x, _y, and _radius are real numbers.
    if (!is_real(_x) || !is_real(_y) || !is_real(_radius)) {
        show_debug_message("ERROR: scr_point_in_sprite() — Invalid parameters: _x, _y, or _radius are not real numbers.");
        return false;
    }
    if (_radius < 0) {
        show_debug_message("WARNING: scr_point_in_sprite() — Negative _radius provided. Using absolute value.");
        _radius = abs(_radius);
    }
    #endregion
    #region 1.2 Pre-condition Checks
    // The original script checked for sprite_exists(_id.sprite_index).
    // However, since this function now focuses on a circular radius around the instance's origin (x,y),
    // the existence of a sprite is not strictly necessary for the core logic (point_in_circle).
    // If sprite-specific calculations were to be reintroduced, this check would be relevant here.
    // For now, we rely on instance_exists(_id) which implies _id.x and _id.y are accessible.
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // No local constants needed beyond the _radius parameter.
    #endregion
    #region 2.2 Configuration from Parameters/Globals
    // The _radius parameter itself is a key configuration.
    // The original script had logic to adjust the radius based on sprite dimensions:
    // var _sprite_width = sprite_get_width(_id.sprite_index) * abs(_id.image_xscale);
    // var _sprite_height = sprite_get_height(_id.sprite_index) * abs(_id.image_yscale);
    // var _adjusted_radius = max(_sprite_width, _sprite_height) + 80;
    // This has been removed to simplify the function to a pure point-in-circle check
    // based on the provided _radius or its default. If sprite-adaptive radius is needed,
    // that logic could be re-integrated here or in a separate function.
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
    // Check if the point (_x, _y) is within the circle defined by the instance's position (_id.x, _id.y) and the given _radius.
    // The point_in_circle function is a built-in GameMaker function that performs this check.
    // It returns true if the point is inside or on the edge of the circle, and false otherwise.
    return point_in_circle(_x, _y, _id.x, _id.y, _radius);
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup (if necessary)
    // No specific cleanup is required for this function.
    #endregion
    #region 5.2 Return Value
    // The return value is directly provided by the point_in_circle function in section 4.1.
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // Example:
    // if (global.debug_mode) {
    //     var _is_inside = point_in_circle(_x, _y, _id.x, _id.y, _radius);
    //     show_debug_message(string_format("scr_point_in_sprite: Point ({0},{1}) vs Instance {2} (at {3},{4}) with radius {5}. Result: {6}", _x, _y, _id, _id.x, _id.y, _radius, _is_inside));
    // }
    #endregion
}
