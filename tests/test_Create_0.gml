/// @desc Tests for obj_pop Create Event initialization

// Mock dependencies
enum PopState { IDLE, MOVING, FORAGING }
// Updated EntityType to reflect a specific Hominid from the new scr_database.gml
// POP_HOMINID is obsolete.
enum EntityType { POP_HOMO_HABILIS_EARLY }

// Updated mock get_entity_data to use the new enum and return 'base_speed_units_sec'
// as per the updated scr_database.gml.
function get_entity_data(type) {
    if (type == EntityType.POP_HOMO_HABILIS_EARLY) {
        // The field name for speed in the main entity database is now 'base_speed_units_sec'.
        // The test previously checked for 'base_speed'.
        return { base_speed_units_sec: 2.5, name: "Mock Habilis" }; // Added name for potential future use in tests
    }
    return undefined;
}
function scr_generate_pop_details() {
    pop_identifier_string = "POP_001";
    pop_name = "Test Pop";
    sex = "M";
    age = 25;
    image_xscale = 1;
    image_yscale = 1;
}
spr_man_idle = 100; // Dummy sprite index
room_speed = 60;

// --- Test Setup ---
var inst = instance_create_layer(100, 200, "Instances", obj_pop);

// --- Test 1: Core State Initialization ---
assert(inst.state == PopState.IDLE, "State should be IDLE");
assert(inst.selected == false, "Selected should be false");
assert(inst.depth == -inst.y, "Depth should be -y");
assert(inst.image_speed == 1, "Image speed should be 1");
assert(inst.sprite_index == spr_man_idle, "Sprite index should be spr_man_idle");
assert(inst.image_index == 0, "Image index should be 0");
assert(inst.current_sprite == spr_man_idle, "Current sprite should be spr_man_idle");
assert(inst.is_mouse_hovering == false, "is_mouse_hovering should be false");

// --- Test 2: Pop Data ---
assert(is_struct(inst.pop), "Pop should be a struct");
// Updated to check for 'base_speed_units_sec' to match the new field name in scr_database.gml
// and the updated mock get_entity_data.
assert(inst.pop.base_speed_units_sec == 2.5, "Pop base_speed_units_sec should be 2.5");

// --- Test 3: Movement & Command Vars ---
// Assuming inst.speed is set based on pop.base_speed_units_sec in obj_pop's Create event.
assert(inst.speed == 2.5, "Speed should match pop.base_speed_units_sec");
assert(inst.direction >= 0 && inst.direction < 360, "Direction should be in [0,360)");
assert(inst.travel_point_x == inst.x, "travel_point_x should be x");
assert(inst.travel_point_y == inst.y, "travel_point_y should be y");
assert(inst.has_arrived == true, "has_arrived should be true");
assert(inst.was_commanded == false, "was_commanded should be false");
assert(inst.order_id == 0, "order_id should be 0");
assert(inst.is_waiting == false, "is_waiting should be false");

// --- Test 4: Idle State Variables ---
assert(inst.idle_timer == 0, "idle_timer should be 0");
assert(inst.idle_target_time == 0, "idle_target_time should be 0");
assert(inst.idle_min_sec == 2.0, "idle_min_sec should be 2.0");
assert(inst.idle_max_sec == 4.0, "idle_max_sec should be 4.0");
assert(inst.after_command_idle_time == 0.5, "after_command_idle_time should be 0.5");

// --- Test 5: Wander State Variables ---
assert(inst.wander_pts == 0, "wander_pts should be 0");
assert(inst.wander_pts_target == 0, "wander_pts_target should be 0");
assert(inst.min_wander_pts == 1, "min_wander_pts should be 1");
assert(inst.max_wander_pts == 3, "max_wander_pts should be 3");
assert(inst.wander_min_dist == 50, "wander_min_dist should be 50");
assert(inst.wander_max_dist == 150, "wander_max_dist should be 150");

// --- Test 6: Foraging State Variables ---
assert(inst.target_bush == noone, "target_bush should be noone");
assert(inst.forage_timer == 0, "forage_timer should be 0");
assert(inst.forage_rate == room_speed, "forage_rate should be room_speed");

// --- Test 7: Interaction Variables ---
assert(inst.target_interaction_object_id == noone, "target_interaction_object_id should be noone");
assert(inst._slot_index == -1, "_slot_index should be -1");
assert(inst._interaction_type_tag == "", "_interaction_type_tag should be empty string");

// --- Test 8: Pop Details Generated ---
assert(is_string(inst.pop_identifier_string), "pop_identifier_string should be string");
assert(is_string(inst.pop_name), "pop_name should be string");
assert(is_string(inst.sex), "sex should be string");
assert(is_real(inst.age), "age should be real");
assert(is_real(inst.image_xscale), "image_xscale should be real");
assert(is_real(inst.image_yscale), "image_yscale should be real");

// --- Test 9: Inventory ---
assert(is_struct(inst.inventory), "inventory should be a struct");
assert(array_length(inst.inventory) == 0, "inventory should be empty struct");

// --- Cleanup ---
instance_destroy(inst);