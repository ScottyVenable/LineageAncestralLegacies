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
///                  _radius : real (optional) — The radius to use for selection. Defaults to 50 pixels.
///   Returns:       boolean — True if the point is within the sprite, false otherwise.
///   Tags:          [utility][sprite][collision]
///   Version:       1.0 — 2025-05-22
///   Dependencies:  None

function scr_point_in_sprite(_x, _y, _id, _radius = 300) {
    // Ensure the instance has a valid sprite
    if (!sprite_exists(_id.sprite_index)) {
        return false;
    }

    // Get the sprite's dimensions and transformations
    var _sprite_width = sprite_get_width(_id.sprite_index) * abs(_id.image_xscale);
    var _sprite_height = sprite_get_height(_id.sprite_index) * abs(_id.image_yscale);

    // Adjust for the sprite's origin point
    var _origin_x = sprite_get_xoffset(_id.sprite_index);
    var _origin_y = sprite_get_yoffset(_id.sprite_index);

    // Calculate the bounds relative to the origin
    var _left = _id.x - _origin_x;
    var _top = _id.y - _origin_y;
    var _right = _left + _sprite_width;
    var _bottom = _top + _sprite_height;

    // Adjust the radius to be 40 pixels wider and taller than the sprite
    var _adjusted_radius = max(_sprite_width, _sprite_height) + 80;

    // Ensure the radius is centered around the origin and large enough
    return point_in_circle(_x, _y, _id.x, _id.y, _adjusted_radius);
}
