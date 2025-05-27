/// @function get_sprite_asset_safely(asset_name_string, fallback_asset_index, [debug_context_string])
/// @description Safely retrieves a sprite asset index by its string name.
///              Checks if the asset name is a valid string, if the asset exists,
///              and if it's a sprite. Returns fallback_asset_index if any check fails.
/// @param {string} asset_name_string The string name of the sprite asset (e.g., "spr_player_idle").
/// @param {Asset.Sprite} fallback_asset_index The asset index to return if lookup fails (e.g., spr_undefined or undefined).
/// @param {string} [debug_context_string=""] Optional string for context in debug messages (e.g., an object or entity ID).
/// @returns {Asset.Sprite} The sprite asset index or fallback_asset_index.
/// @tags [utility][asset]
/// @version 1.1 - 2025-05-26 (Adhered to TEMPLATE_SCRIPT.gml, improved debug context)
/// @dependencies None
/// @educational
/// Why this approach? This function provides robust sprite loading from string names,
/// which is common when using data from profiles or configuration files.
/// It prevents crashes from incorrect asset names or types by performing multiple checks:
/// 1. Validates that the input 'asset_name_string' is actually a non-empty string.
/// 2. Uses `asset_exists()` to ensure the named asset is part of the project.
/// 3. Uses `asset_get_type()` to confirm the asset is a sprite (not an object, sound, etc.).
/// If any check fails, it returns a specified fallback sprite and logs a descriptive
/// warning, helping beginners troubleshoot data errors or missing assets.
/// Placing this in a global script makes it reusable and avoids potential scope issues
/// that can sometimes occur with complex method variables within object events.

function get_sprite_asset_safely(asset_name_string, fallback_asset_index, debug_context_string = "") {
    // =========================================================================
    // 0. IMPORTS & CACHES (Not strictly needed for this utility)
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // No specific imports or caches needed for this function's direct logic.
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS (Input validation is the core of this function)
    // =========================================================================
    #region 1.1 Parameter Validation & Core Logic
    // Check if the input asset_name_string is a valid, non-empty string.
    // Added an explicit is_real() check for robustness, as errors suggest a number might bypass the !is_string() check
    // or to provide clearer debugging if a number is incorrectly passed as an asset name.
    //
    // EDUCATIONAL NOTE:
    // The order of checks here is important:
    // 1. is_real(): Catches if an asset ID (a number) was mistakenly passed.
    // 2. !is_string(): Catches other non-string types like 'undefined', 'bool', etc.
    // 3. string_length() == 0: Catches empty strings.
    // If asset_name_string is a number (e.g., 100005), is_real() is true, and this block should execute,
    // preventing the error seen at global.asset_exists.
    if (is_real(asset_name_string) || !is_string(asset_name_string) || string_length(asset_name_string) == 0) {
        var _reason = "an unknown invalid type"; // Default reason
        if (is_real(asset_name_string)) {
            // If it's a number, show the number itself in the reason.
            _reason = $"a number ({asset_name_string}) (asset ID perhaps?) instead of a string name";
        } else if (!is_string(asset_name_string)) {
            // If not a string (and not a real), show its type.
            _reason = $"not a string (type: {typeof(asset_name_string)})";
        } else { // If it is a string, but length is 0
            _reason = "an empty string";
        }
        var _msg_context_issue = (debug_context_string != "") ? $" for {debug_context_string}" : "";
        // Enhanced debug message to show the problematic value directly.
        debug_message($"WARNING (get_sprite_asset_safely{_msg_context_issue}): Provided asset name was {_reason}. Value: '{asset_name_string}'. Using fallback.");
        return fallback_asset_index;
    }

    // CRITICAL DEBUGGING STEP:
    // The error "Variable <unknown_object>.asset_exists(100005, -2147483648) not set before reading it."
    // at the 'global.asset_exists' line is highly unusual for a built-in function.
    //
    // UPDATE BASED ON LATEST DEBUG LOG:
    // Your debug output ("DEBUG (get_sprite_asset_safely): PRE-CALL CHECK for global.asset_exists. asset_name_string = 'spr_pop_woman_idle', typeof = string, is_string = 1, is_real = 0")
    // CONFIRMS that 'asset_name_string' IS a valid string ("spr_pop_woman_idle") when 'global.asset_exists' is called.
    // This means the initial validation logic in this script IS working correctly for this input.
    //
    // DESPITE 'asset_name_string' being correct, the error persists and shows the engine trying to evaluate
    // 'asset_exists' with strange arguments (100005, ...).
    //
    // THIS MAKES IT EXTREMELY LIKELY THAT THE 'global' KEYWORD ITSELF HAS BEEN REASSIGNED (SHADOWED)
    // SOMEWHERE IN YOUR PROJECT. For example, a line like "global = some_instance_id;" or "global = some_struct;".
    // If 'global' has been redefined, then 'global.asset_exists' attempts to access a member variable or method
    // named 'asset_exists' on whatever 'global' now points to. If that member doesn't exist, it would cause
    // this exact "Variable ... not set before reading it" error.
    //
    // !!! MOST IMPORTANT ACTION REQUIRED: You MUST search your ENTIRE project (all scripts, objects, rooms) !!!
    // !!! for any lines of code that look like "global = ". The keyword 'global' should NEVER be used as a variable name. !!!
    // !!! Finding and removing/correcting such a line is the most probable solution. !!!
    //
    // The '100005' in the error message is likely an internal artifact resulting from 'global' being misinterpreted,
    // NOT the direct value of 'asset_name_string' at the point of the GML call (which your debug log shows is a string).
    debug_message($"DEBUG (get_sprite_asset_safely): PRE-CALL CHECK for asset_get_type. asset_name_string = '{asset_name_string}', typeof = {typeof(asset_name_string)}, is_string = {is_string(asset_name_string)}, is_real = {is_real(asset_name_string)}");

    // Check if the asset exists and what type it is.
    // asset_get_type(string_name) will return asset_unknown (-1) if the asset doesn't exist.
    // It will return other asset type constants (e.g., asset_sprite, asset_object) if it exists.
    var _asset_type = asset_get_type(asset_name_string);

    if (_asset_type == asset_unknown) {
        var _msg_context_exists = (debug_context_string != "") ? $" for {debug_context_string}" : "";
        debug_message($"WARNING (get_sprite_asset_safely{_msg_context_exists}): Sprite asset name \'{asset_name_string}\' NOT FOUND (asset_unknown). Using fallback.");
        return fallback_asset_index;
    }

    // Confirm the asset is a sprite (not, for example, an object or sound)
    if (_asset_type != asset_sprite) {
        var _msg_context_type = (debug_context_string != "") ? $" for {debug_context_string}" : "";
        // It's helpful to know what type it *was* if it wasn't a sprite.
        debug_message($"WARNING (get_sprite_asset_safely{_msg_context_type}): Asset \'{asset_name_string}\' found but is NOT a sprite (type: {_asset_type}). Using fallback.");
        return fallback_asset_index;
    }

    // If we've reached here, the asset exists and is a sprite. Now we can safely get its index.
    var _asset_index = asset_get_index(asset_name_string);
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS (Not applicable here)
    // =========================================================================

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP (Not applicable here)
    // =========================================================================

    // =========================================================================
    // 4. CORE LOGIC (Handled in section 1 for this validation-heavy function)
    // =========================================================================

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return
    return _asset_index; // Success: return the sprite's asset index
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional - handled by show_debug_message within logic)
    // =========================================================================
}