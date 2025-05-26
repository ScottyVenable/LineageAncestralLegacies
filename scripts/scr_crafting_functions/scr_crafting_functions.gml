/// scr_crafting_functions.gml
///
/// Purpose:
///   Provides functions for managing crafting recipes, checking if a recipe can be crafted,
///   and performing the crafting action (consuming ingredients, adding results to inventory).
///
/// Metadata:
///   Summary:       Handles game crafting logic based on JSON-defined recipes.
///   Usage:         `can_craft_recipe(pop_instance, recipe_id)` to check, 
///                  `perform_craft_recipe(pop_instance, recipe_id)` to execute.
///   Parameters:    Varies by function.
///   Returns:       Varies by function.
///   Tags:          [crafting][inventory][recipes][gameplay][systems]
///   Version:       1.0 - 2025-05-26
///   Dependencies:  `scr_data_helpers` (for `get_recipe_by_id`, `get_item_profile_by_id`),
///                  `scr_inventory_functions` (for `inventory_has_items`, `inventory_remove_items`, `inventory_add_item`).
///                  Pop instances need an `inventory` (e.g., ds_grid or struct).
///                  `global.GameData.recipes` and `global.GameData.items` must be loaded.
///   Creator:       Copilot
///   Created:       2025-05-26
///   Last Modified: 2025-05-26 by Copilot

// =========================================================================
// 4. CORE LOGIC (Function Definitions)
// =========================================================================

#region 4.1 Can Craft Recipe: can_craft_recipe()
/// @function can_craft_recipe(_pop_instance, _recipe_id)
/// @description Checks if the given pop has the required ingredients in their inventory to craft the specified recipe.
/// @param {Id.Instance} _pop_instance The pop instance attempting to craft.
/// @param {String} _recipe_id The ID of the recipe to check (from global.GameData.recipes).
/// @returns {Bool} True if the pop can craft the recipe, false otherwise.
function can_craft_recipe(_pop_instance, _recipe_id) {
    // =========================================================================
    // 4.1.1. VALIDATION & EARLY RETURNS
    // =========================================================================
    if (!instance_exists(_pop_instance)) {
        show_debug_message("ERROR (can_craft_recipe): Invalid pop instance provided.");
        return false;
    }
    // Assuming inventory_has_items script is available and handles inventory existence checks.
    // if (!variable_instance_exists(_pop_instance, "inventory")) { 
    //     show_debug_message("ERROR (can_craft_recipe): Pop " + string(_pop_instance.id) + " has no inventory.");
    //     return false; 
    // }

    var _recipe_data = get_recipe_by_id(_recipe_id);
    if (is_undefined(_recipe_data)) {
        show_debug_message("ERROR (can_craft_recipe): Recipe ID '" + _recipe_id + "' not found.");
        return false;
    }
    if (!is_struct(_recipe_data.ingredients)) {
        show_debug_message("ERROR (can_craft_recipe): Recipe '" + _recipe_id + "' has no ingredients defined or ingredients are not a struct.");
        return false;
    }

    // =========================================================================
    // 4.1.4. CORE LOGIC - Check Ingredients
    // =========================================================================
    var _ingredient_keys = variable_struct_get_names(_recipe_data.ingredients);
    for (var i = 0; i < array_length(_ingredient_keys); i++) {
        var _item_id = _ingredient_keys[i];
        var _required_count = _recipe_data.ingredients[_item_id];
        
        // Assuming inventory_has_items(instance, item_id, count) exists
        if (!inventory_has_items(_pop_instance, _item_id, _required_count)) {
            // show_debug_message("Pop " + string(_pop_instance.id) + " cannot craft " + _recipe_id + ". Missing: " + string(_required_count) + "x " + _item_id);
            return false; // Missing one or more ingredients
        }
    }
    
    return true; // All ingredients are present in sufficient quantities
}
#endregion

#region 4.2 Perform Craft Recipe: perform_craft_recipe()
/// @function perform_craft_recipe(_pop_instance, _recipe_id)
/// @description Attempts to craft the recipe. If successful, consumes ingredients and adds the result to the pop's inventory.
/// @param {Id.Instance} _pop_instance The pop instance performing the craft.
/// @param {String} _recipe_id The ID of the recipe to craft.
/// @returns {Bool} True if crafting was successful, false otherwise.
function perform_craft_recipe(_pop_instance, _recipe_id) {
    // =========================================================================
    // 4.2.1. VALIDATION & PRE-CONDITION CHECK (Can Craft?)
    // =========================================================================
    if (!can_craft_recipe(_pop_instance, _recipe_id)) {
        show_debug_message("INFO (perform_craft_recipe): Pop " + string(_pop_instance.id) + " cannot craft recipe '" + _recipe_id + "' due to missing ingredients or invalid recipe.");
        return false;
    }

    var _recipe_data = get_recipe_by_id(_recipe_id); // Already validated by can_craft_recipe, but good to have locally.
    // No need to re-validate _recipe_data structure here as can_craft_recipe would have failed.

    // =========================================================================
    // 4.2.4. CORE LOGIC - Consume Ingredients & Add Result
    // =========================================================================
    
    // --- 4.2.4.1 Consume Ingredients ---
    var _ingredient_keys = variable_struct_get_names(_recipe_data.ingredients);
    for (var i = 0; i < array_length(_ingredient_keys); i++) {
        var _item_id = _ingredient_keys[i];
        var _count_to_remove = _recipe_data.ingredients[_item_id];
        
        // Assuming inventory_remove_items(instance, item_id, count) exists and returns true on success
        if (!inventory_remove_items(_pop_instance, _item_id, _count_to_remove)) {
            // This should ideally not happen if can_craft_recipe passed and inventory is handled atomically.
            // This could indicate a race condition or a bug in inventory_remove_items or inventory_has_items.
            show_debug_message("CRITICAL ERROR (perform_craft_recipe): Failed to remove ingredient '" + _item_id + "' for recipe '" + _recipe_id + "' even after can_craft_recipe check passed. Crafting aborted.");
            // TODO: Consider a rollback mechanism for already removed items if crafting is multi-step and can fail midway.
            return false; 
        }
    }

    // --- 4.2.4.2 Add Result Item(s) ---
    if (is_struct(_recipe_data.result)) {
        var _result_item_id = _recipe_data.result.id;
        var _result_item_count = _recipe_data.result.count;
        var _item_profile = get_item_profile_by_id(_result_item_id);

        if (is_undefined(_item_profile)) {
            show_debug_message("ERROR (perform_craft_recipe): Result item ID '" + _result_item_id + "' for recipe '" + _recipe_id + "' does not have a valid item profile. Crafting failed, ingredients consumed.");
            // This is a data integrity issue. Ingredients were consumed.
            return false; 
        }
        
        // Assuming inventory_add_item(instance, item_id, count) or similar exists
        // This might need to handle stacking, creating new item instances, etc.
        // For simplicity, let's assume it takes item_id and count.
        if (!inventory_add_item(_pop_instance, _result_item_id, _result_item_count)) {
             show_debug_message("ERROR (perform_craft_recipe): Failed to add result item '" + _result_item_id + "' to inventory for pop " + string(_pop_instance.id) + ". Inventory might be full. Ingredients consumed.");
            // Ingredients were consumed, but item couldn't be added.
            // TODO: Consider dropping item on ground or other fallback.
            return false;
        }
        show_debug_message("Pop " + string(_pop_instance.id) + " successfully crafted " + string(_result_item_count) + "x " + _result_item_id + " ('" + _recipe_id + "').");
    } else {
        show_debug_message("WARNING (perform_craft_recipe): Recipe '" + _recipe_id + "' has no result defined or result is not a struct. Ingredients consumed, nothing produced.");
        // Ingredients consumed, but no result to give.
    }
    
    return true; // Crafting successful
}
#endregion

#region 4.3 Get Craftable Recipes: get_craftable_recipes_for_pop()
/// @function get_craftable_recipes_for_pop(_pop_instance)
/// @description Returns a list of recipe IDs that the given pop can currently craft.
/// @param {Id.Instance} _pop_instance The pop instance.
/// @returns {Array<String>} An array of recipe IDs that are craftable.
function get_craftable_recipes_for_pop(_pop_instance) {
    var _craftable_list = [];
    if (!instance_exists(_pop_instance) || !variable_global_exists("GameData") || !is_struct(global.GameData.recipes)) {
        return _craftable_list; // Return empty if pop or recipes are invalid
    }

    var _all_recipe_ids = variable_struct_get_names(global.GameData.recipes);
    for (var i = 0; i < array_length(_all_recipe_ids); i++) {
        var _recipe_id = _all_recipe_ids[i];
        if (can_craft_recipe(_pop_instance, _recipe_id)) {
            array_push(_craftable_list, _recipe_id);
        }
    }
    return _craftable_list;
}
#endregion
