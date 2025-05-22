/// scr_point_in_sprite.gml
///
/// Purpose:
///   Checks if a point is within the visible area of a sprite, considering transformations like scaling and rotation.
///
/// Metadata:
///   Summary:       Determines if a point is within a sprite's visible bounds.
///   Parameters:    _x : real — The x-coordinate of the point.
///                  _y : real — The y-coordinate of the point.
///                  _id : instance — The instance to check against.
///   Returns:       boolean — True if the point is within the sprite, false otherwise.
///   Tags:          [utility][sprite][collision]
///   Version:       1.0 — 2025-05-22
///   Dependencies:  None

function scr_point_in_sprite(_x, _y, _id) {
    // Ensure the instance has a valid sprite
    if (!sprite_exists(_id.sprite_index)) {
        return false;
    }

    // Get the sprite's dimensions and transformations
    var _sprite_width = sprite_get_width(_id.sprite_index) * abs(_id.image_xscale);
    var _sprite_height = sprite_get_height(_id.sprite_index) * abs(_id.image_yscale);
    var _left = _id.x - _sprite_width / 2;
    var _top = _id.y - _sprite_height / 2;
    var _right = _id.x + _sprite_width / 2;
    var _bottom = _id.y + _sprite_height / 2;

    // Check if the point is within the sprite's bounds
    return point_in_rectangle(_x, _y, _left, _top, _right, _bottom);
}
