/// scr_ds_list_to_array.gml
///
/// Purpose:
///   Converts a GameMaker ds_list into a standard array. This is useful for
///   situations where array-specific functions are needed or when interfacing
///   with systems that expect arrays.
///
/// Metadata:
///   Summary:       Converts a ds_list to an array.
///   Usage:         Call to transform an existing ds_list into a new array.
///                  e.g., var _my_array = scr_ds_list_to_array(my_ds_list);
///   Parameters:    _ds_list : id — The ds_list to convert.
///   Returns:       array — A new array containing all elements from the _ds_list in the same order.
///                          Returns an empty array if the input is not a valid ds_list or is empty.
///   Tags:          [utility][ds_list][array][conversion][data_structure]
///   Version:       1.0 - 2025-05-23 // Initial creation, conforms to TEMPLATE_SCRIPT.
///   Dependencies:  None
///   Creator:       Copilot
///   Created:       2025-05-23
///   Last Modified: 2025-05-23 by Copilot

function scr_ds_list_to_array(_ds_list) {
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
    // Check if the provided _ds_list is actually a ds_list.
    // ds_exists is crucial here to prevent errors with invalid IDs.
    if (!ds_exists(_ds_list, ds_type_list)) {
        show_debug_message("ERROR: scr_ds_list_to_array() — Invalid _ds_list parameter: not a valid ds_list or does not exist.");
        return []; // Return an empty array on invalid input.
    }
    #endregion
    #region 1.2 Pre-condition Checks
    // Check if the ds_list is empty. If so, can return an empty array early.
    if (ds_list_empty(_ds_list)) {
        return [];
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // Get the size of the ds_list to iterate through it.
    var _list_size = ds_list_size(_ds_list);
    #endregion
    #region 2.2 Configuration from Parameters/Globals
    // No specific configurations derived from parameters or global settings for this utility.
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One-Time Setup / State Variables
    // Initialize an empty array to store the ds_list elements.
    // GameMaker arrays can be dynamically resized, but if performance were critical
    // for very large lists, one might pre-allocate using array_create(_list_size);
    // However, for general utility, dynamic pushing is fine.
    var _array = [];
    #endregion

    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1 Main Behavior / Utility Logic
    // Iterate through the ds_list and add each element to the new array.
    // ds_list elements are accessed by index, similar to arrays.
    for (var i = 0; i < _list_size; i++) {
        // Retrieve the element at the current index from the ds_list.
        var _element = ds_list_find_value(_ds_list, i);
        // Add (push) the element to the end of the _array.
        array_push(_array, _element);
    }
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup (if necessary)
    // This function creates a new array but does NOT destroy the original ds_list.
    // The caller is responsible for managing the lifecycle of the input ds_list.
    #endregion
    #region 5.2 Return Value
    // Return the newly created array.
    return _array;
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // Example:
    // if (global.debug_mode) {
    //     show_debug_message(string_format("scr_ds_list_to_array: Converted ds_list (id: {0}, size: {1}) to array (size: {2}).", _ds_list, _list_size, array_length(_array)));
    // }
    #endregion
}
