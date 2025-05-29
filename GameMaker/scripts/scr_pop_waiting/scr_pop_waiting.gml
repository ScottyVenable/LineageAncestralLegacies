/// scr_pop_waiting.gml
///
/// A true “waiting” state—just sits and shows the WAITING sprite/text.

function scr_pop_waiting() {
    // Animation swap (reuse your idle animation or create a special one)
    if (sprite_index != spr_pop_man_idle) {
        sprite_index = spr_pop_man_idle;
        image_index  = 0;
    }

    // Don’t move
    speed = 0;
	

    // No timer here — stays until we explicitly clear it
}
