/// @description Initializes the interaction point.
//
// Purpose:
//  Sets up variables to link this point to its parent provider (e.g., a berry bush)
//  and define its behavior.
//
// Variables:
//  parent_provider_id: Instance ID of the object that created this point (e.g., obj_redBerryBush).
//  slot_index_on_parent: The numerical index this point represents in the parent's slot array.
//  interaction_type_tag: A string tag defining the type of interaction (e.g., "forage_left", "gather_wood").
//  is_occupied_by_pop_id: Stores the ID of the pop currently assigned to or using this point, 'noone' if free.

parent_provider_id = noone;      // Will be set by the object that creates this point.
slot_index_on_parent = -1;       // Will be set by the object that creates this point.
interaction_type_tag = "";       // Will be set by the object that creates this point.
is_occupied_by_pop_id = noone; // Tracks which pop has claimed this specific point.

// --- Visuals & Debug ---
// Set to true to see the points in-game, false to hide them.
// You might want to assign a specific debug sprite as well.
visible = true; 
image_alpha = 1; // Make it semi-transparent
image_speed = 0;
image_xscale = 1;
image_yscale = 1;

// It's good practice for interaction points not to be solid if they are just markers.
// If pops need to collide with them for some reason, this might change.
// For now, assuming they are non-solid targets.
mask_index = -1; // No collision mask

/*
// Example Debug Sprite (spr_interaction_point_debug):
// A simple small circle or crosshair sprite would work well.
// Origin: Middle Center
*/
