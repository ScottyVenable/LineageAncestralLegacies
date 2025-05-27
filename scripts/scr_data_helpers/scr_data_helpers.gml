/// @function get_enum_value_from_string(_enum_name, _string_value)
/// @description Converts a string value to its corresponding enum member value.
/// @param {string} _enum_name The name of the enum (e.g., "ItemCategory").
/// @param {string} _string_value The string representation of the enum member (e.g., "Food").
/// @returns {*} The enum member value, or undefined if not found.
function get_enum_value_from_string(_enum_name, _string_value) {
    // This function is a placeholder. GameMaker Language doesn't have built-in reflection
    // for enums in a way that allows dynamic lookup by string name of the enum itself.
    // You would typically implement this with a switch statement or a map for each enum.
    // For now, we'll return undefined and log a warning.
    show_debug_message("WARNING: get_enum_value_from_string - Dynamic enum lookup for '" + _enum_name + "' is not fully supported. String value: " + _string_value);
    
    // Example for a specific enum (you'd need to expand this or use a different approach)
    // if (_enum_name == "MyEnum") {
    //     switch (_string_value) {
    //         case "ValueA": return MyEnum.ValueA;
    //         case "ValueB": return MyEnum.ValueB;
    //         // ... other cases
    //     }
    // }
    return undefined;
}

/// @function get_item_profile_by_id(_item_id)
/// @description Retrieves an item's profile data from global.GameData.items.
/// @param {string} _item_id The unique identifier of the item (e.g., "berries", "stone_axe").
/// @returns {struct} The item's profile struct, or undefined if not found.
function get_item_profile_by_id(_item_id) {
    // =========================================================================
    // Helper_1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region Helper_1.1 Parameter Validation
    if (!is_string(_item_id) || string_length(_item_id) == 0) {
        show_debug_message("ERROR (get_item_profile_by_id): Invalid or empty _item_id provided.");
        return undefined;
    }
    #endregion
    #region Helper_1.2 Pre-condition Checks - GameData Existence
    if (!variable_global_exists("GameData") || !is_struct(global.GameData) || !variable_struct_exists(global.GameData, "items")) {
        show_debug_message("ERROR (get_item_profile_by_id): global.GameData.items is not initialized.");
        return undefined;
    }
    #endregion

    // =========================================================================
    // Helper_4. CORE LOGIC - Profile Lookup
    // =========================================================================
    #region Helper_4.1 Lookup Item Profile
    // Iterate through the main categories in global.GameData.items (e.g., "Resource", "Tool", "Food")
    var _item_categories = variable_struct_get_names(global.GameData.items);
    for (var i = 0; i < array_length(_item_categories); i++) {
        var _category_key = _item_categories[i];
        var _category_struct = global.GameData.items[$ _category_key];

        // Check if the current category is a struct
        if (!is_struct(_category_struct)) continue;

        // Iterate through items within this category
        var _items_in_category = variable_struct_get_names(_category_struct);
        for (var j = 0; j < array_length(_items_in_category); j++) {
            var _item_key_in_category = _items_in_category[j];
            var _item_profile = _category_struct[$ _item_key_in_category];

            // Check if this item profile is a struct and has the 'item_id_string' field
            if (is_struct(_item_profile) && variable_struct_exists(_item_profile, "item_id_string")) {
                if (_item_profile.item_id_string == _item_id) {
                    return _item_profile; // Found the item profile
                }
            }
        }
    }

    // If the loop completes without finding the item
    show_debug_message("WARNING (get_item_profile_by_id): Item profile not found for ID: " + _item_id);
    return undefined;
    #endregion
}

/// @function get_resource_node_profile_by_id(_node_id)
/// @description Retrieves a resource node's profile data from global.GameData.resource_nodes.
/// @param {string} _node_id The unique identifier of the resource node (e.g., "tree_pine", "rock_iron_ore").
/// @returns {struct} The resource node's profile struct, or undefined if not found.
function get_resource_node_profile_by_id(_node_id) {
    // Validation and GameData checks (similar to get_item_profile_by_id)
    if (!is_string(_node_id) || string_length(_node_id) == 0) return undefined;
    if (!variable_global_exists("GameData") || !is_struct(global.GameData) || !variable_struct_exists(global.GameData, "resource_nodes")) return undefined;

    if (variable_struct_exists(global.GameData.resource_nodes, _node_id)) {
        return global.GameData.resource_nodes[_node_id];
    } else {
        show_debug_message("WARNING (get_resource_node_profile_by_id): Resource node profile not found for ID: " + _node_id);
        return undefined;
    }
}

/// @function get_structure_profile_by_id(_structure_id)
/// @description Retrieves a structure's profile data from global.GameData.structures.
/// @param {string} _structure_id The unique identifier of the structure (e.g., "hut_basic", "storage_small").
/// @returns {struct} The structure's profile struct, or undefined if not found.
function get_structure_profile_by_id(_structure_id) {
    // Validation and GameData checks
    if (!is_string(_structure_id) || string_length(_structure_id) == 0) return undefined;
    if (!variable_global_exists("GameData") || !is_struct(global.GameData) || !variable_struct_exists(global.GameData, "structures")) return undefined;

    if (variable_struct_exists(global.GameData.structures, _structure_id)) {
        return global.GameData.structures[_structure_id];
    } else {
        show_debug_message("WARNING (get_structure_profile_by_id): Structure profile not found for ID: " + _structure_id);
        return undefined;
    }
}

/// @function get_entity_profile_by_id(_entity_id)
/// @description Retrieves an entity's profile data from global.GameData.entities.
/// @param {string} _entity_id The unique identifier of the entity (e.g., "pop_human", "animal_deer").
/// @returns {struct} The entity's profile struct, or undefined if not found.
function get_entity_profile_by_id(_entity_id) {
    // Validation and GameData checks
    if (!is_string(_entity_id) || string_length(_entity_id) == 0) return undefined;
    if (!variable_global_exists("GameData") || !is_struct(global.GameData) || !variable_struct_exists(global.GameData, "entities")) return undefined;

    if (variable_struct_exists(global.GameData.entities, _entity_id)) {
        return global.GameData.entities[_entity_id];
    } else {
        show_debug_message("WARNING (get_entity_profile_by_id): Entity profile not found for ID: " + _entity_id);
        return undefined;
    }
}

/// @function get_pop_state_profile_by_id(_state_id)
/// @description Retrieves a pop state's profile data from global.GameData.pop_states.
/// @param {string} _state_id The unique identifier of the pop state (e.g., "Idle", "Foraging").
/// @returns {struct} The pop state's profile struct, or undefined if not found.
function get_pop_state_profile_by_id(_state_id) {
    // Validation and GameData checks
    if (!is_string(_state_id) || string_length(_state_id) == 0) return undefined;
    if (!variable_global_exists("GameData") || !is_struct(global.GameData) || !variable_struct_exists(global.GameData, "pop_states")) return undefined;

    if (variable_struct_exists(global.GameData.pop_states, _state_id)) {
        return global.GameData.pop_states[_state_id];
    } else {
        show_debug_message("WARNING (get_pop_state_profile_by_id): Pop state profile not found for ID: " + _state_id);
        return undefined;
    }
}

/// @function get_recipe_by_id(_recipe_id)
/// @description Retrieves a recipe's data from global.GameData.recipes.
/// @param {string} _recipe_id The unique identifier of the recipe (e.g., "wooden_pickaxe").
/// @returns {struct} The recipe's struct, or undefined if not found.
function get_recipe_by_id(_recipe_id) {
    // Validation and GameData checks
    if (!is_string(_recipe_id) || string_length(_recipe_id) == 0) return undefined;
    if (!variable_global_exists("GameData") || !is_struct(global.GameData) || !variable_struct_exists(global.GameData, "recipes")) return undefined;

    if (variable_struct_exists(global.GameData.recipes, _recipe_id)) {
        return global.GameData.recipes[_recipe_id];
    } else {
        show_debug_message("WARNING (get_recipe_by_id): Recipe not found for ID: " + _recipe_id);
        return undefined;
    }
}
