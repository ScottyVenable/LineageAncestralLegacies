/// scr_ds_list_to_array.gml
///
/// Purpose:
///   Converts a ds_list into a standard GML array.
///
/// Metadata:
///   Summary:       Converts a ds_list to an array.
///   Usage:         Utility function for data structure operations.
///   Parameters:    _list : ds_list — The ds_list to convert.
///   Returns:       array — A GML array containing the elements of the ds_list.
///   Tags:          [utility][ds_list][array]
///   Version:       1.0 — 2025-05-22
///   Dependencies:  None

function scr_ds_list_to_array(_list) {
    // Check if the input is a valid ds_list
    if (!ds_exists(_list, ds_type_list)) {
        show_debug_message("Error: Provided input is not a valid ds_list.");
        return []; // Return an empty array if the input is invalid
    }

    // Create an array to store the elements of the ds_list
    var _array = [];

    // Loop through the ds_list and copy each element into the array
    for (var i = 0; i < ds_list_size(_list); i++) {
        array_push(_array, ds_list_find_value(_list, i));
    }

    return _array; // Return the resulting array
}
