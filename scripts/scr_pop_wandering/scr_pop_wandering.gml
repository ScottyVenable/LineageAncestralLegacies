/// scr_pop_wandering.gml
///
/// Picks a random number of stops, hops between them, then returns to IDLE.

function scr_pop_wandering() {
    // 0) Ensure we’re using the walking sprite
    scr_update_walk_sprite();
    speed = 1.25;

    // 1) If we've just entered WANDERING, initialize our stop count
    if (wander_pts == 0 && state == PopState.WANDERING) {
        // Pick how many hops to make this cycle
        wander_pts_target = irandom_range(min_wander_pts, max_wander_pts);
        wander_pts        = 0;
        
        // And immediately choose our first point:
        var ang = irandom(359);
        var dist = random_range(wander_min_dist, wander_max_dist);
        travel_point_x = x + lengthdir_x(dist, ang);
        travel_point_y = y + lengthdir_y(dist, ang);
        direction      = ang;
        
        // We’ll count this as hop #1
        wander_pts += 1;
        return; 
    }

    // 2) Move toward the current target
    direction = point_direction(x, y, travel_point_x, travel_point_y);

    // 3) Check for arrival (within 4 px)
    if (point_distance(x, y, travel_point_x, travel_point_y) < 4) {
        // Snap exactly
        x = travel_point_x;
        y = travel_point_y;
        
        // If we still have hops left, pick the next one…
        if (wander_pts < wander_pts_target) {
            var ang2  = irandom(359);
            var dist2 = random_range(wander_min_dist, wander_max_dist);
            travel_point_x = x + lengthdir_x(dist2, ang2);
            travel_point_y = y + lengthdir_y(dist2, ang2);
            direction      = ang2;
            wander_pts   += 1;
        }
        else {
            // We’ve completed all our hops—reset and go idle
            wander_pts        = 0;
            wander_pts_target = 0;
            speed             = 0;
            state             = PopState.IDLE;
        }
    }
}
