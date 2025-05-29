/// scr_update_walk_sprite.gml
/// Call this every frame when moving to pick the right directional sprite
function scr_update_walk_sprite() {
    // `direction` is your current move angle (0 = right, 90 = down, 180 = left, 270 = up)
    var dir = direction mod 360;

    if (dir >= 45  && dir < 135) {
        // moving downward
        sprite_index = spr_man_walking_down;
    }
    else if (dir >= 135 && dir < 225) {
        // moving left
        sprite_index = spr_man_walking_left;
    }
    else if (dir >= 225 && dir < 315) {
        // moving up
        sprite_index = spr_man_walking_up;
    }
    else {
        // moving right
        sprite_index = spr_man_walking_right;
    }

    image_speed = 1;  // keep your walk speed
}
