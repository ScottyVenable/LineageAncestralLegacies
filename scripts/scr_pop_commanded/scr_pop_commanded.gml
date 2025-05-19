/// scr_pop_commanded.gml
///
/// Handles COMMANDED state: switches to faster walking animation,
/// moves toward the stored travel_point_x/y, snaps on arrival, and returns to IDLE.

function scr_pop_commanded() {
    // 0) On first frame of COMMANDED, ensure walking animation is playing faster
    
    scr_update_walk_sprite()
    image_speed = image_speed * 2

    // 1) Face and move toward the target point
    direction = point_direction(x, y, travel_point_x, travel_point_y);
    speed     = 2;

    // 2) Snap-to-target if within small threshold
    if (point_distance(x, y, travel_point_x, travel_point_y) < 2) {
        x = travel_point_x;
        y = travel_point_y;
    }

    // 3) Arrival check
    if (x == travel_point_x && y == travel_point_y) {
        // Stop movement
        speed       = 0;
        has_arrived = false;          // reset for next command
        was_commanded = true;
        state       = PopState.IDLE;  // go idle
    }
    scr_separate_pops();
}
