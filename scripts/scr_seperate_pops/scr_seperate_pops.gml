/// scr_separate_pops.gml
///
/// Pushes this pop slightly away from any other pop
/// whose collision mask it overlaps.

function scr_separate_pops() {
    // Check for any overlapping pop at our position
    var inst_hit = instance_place(x, y, obj_pop);
    if (inst_hit != noone && inst_hit != id) {
        // Compute a small push vector away from the other pop
        var ang = point_direction(inst_hit.x, inst_hit.y, x, y);
        // Nudge by 1px (tweak as needed)
        x += lengthdir_x(0.5, ang);
        y += lengthdir_y(0.5, ang);
    }
}
