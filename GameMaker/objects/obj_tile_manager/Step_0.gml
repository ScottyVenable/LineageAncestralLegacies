/// @description Manages procedural generation of grass tiles based on camera view.

// =========================================================================
// 1. GET CAMERA VIEW BOUNDARIES
// =========================================================================
// Get the current camera's position and size
var _cam_x = camera_get_view_x(view_camera_main);
var _cam_y = camera_get_view_y(view_camera_main);
var _cam_w = camera_get_view_width(view_camera_main);
var _cam_h = camera_get_view_height(view_camera_main);

// =========================================================================
// 2. DETERMINE VISIBLE CHUNK RANGE
// =========================================================================
// Calculate the range of chunks that *should* be visible or buffered around the camera.
// We add a buffer of 1 chunk around the visible area to preemptively generate.
var _buffer_chunks = 1;

var _start_chunk_x = floor((_cam_x - (_buffer_chunks * CHUNK_WIDTH_PIXELS)) / CHUNK_WIDTH_PIXELS);
var _end_chunk_x   = floor((_cam_x + _cam_w + (_buffer_chunks * CHUNK_WIDTH_PIXELS)) / CHUNK_WIDTH_PIXELS);
var _start_chunk_y = floor((_cam_y - (_buffer_chunks * CHUNK_HEIGHT_PIXELS)) / CHUNK_HEIGHT_PIXELS);
var _end_chunk_y   = floor((_cam_y + _cam_h + (_buffer_chunks * CHUNK_HEIGHT_PIXELS)) / CHUNK_HEIGHT_PIXELS);

// =========================================================================
// 3. ITERATE AND GENERATE MISSING CHUNKS
// =========================================================================
for (var _chunk_y = _start_chunk_y; _chunk_y <= _end_chunk_y; _chunk_y++) {
    for (var _chunk_x = _start_chunk_x; _chunk_x <= _end_chunk_x; _chunk_x++) {
        
        var _chunk_key = string(_chunk_x) + "_" + string(_chunk_y);
        
        // Check if this chunk has already been generated
        if (is_undefined(ds_map_find_value(generated_chunks_map, _chunk_key))) {
            // This chunk is new, generate it!
            // show_debug_message("Generating chunk: " + _chunk_key);
            
            // Calculate the top-left pixel position of this chunk
            var _chunk_origin_x = _chunk_x * CHUNK_WIDTH_PIXELS;
            var _chunk_origin_y = _chunk_y * CHUNK_HEIGHT_PIXELS;
            
            // Fill this chunk with random grass tiles
            for (var _ty = 0; _ty < CHUNK_HEIGHT_TILES; _ty++) {
                for (var _tx = 0; _tx < CHUNK_WIDTH_TILES; _tx++) {
                    // Get a random tile index from your grass tileset
                    // This assumes all tiles in GRASS_TILESET are valid grass tiles.
                    // If your tileset has non-grass tiles or needs specific logic (e.g., auto-tiling),
                    // you'll need to adjust how _random_tile_index is chosen.
                    // For a simple tileset where all tiles are variants, irandom(count-1) is fine.
                    var _random_tile_index = irandom(grass_tile_count - 1); 
                    
                    // Calculate the world position of the tile
                    var _tile_world_x = _chunk_origin_x + (_tx * TILE_WIDTH);
                    var _tile_world_y = _chunk_origin_y + (_ty * TILE_HEIGHT);
                    
                    // Set the tile data on the tilemap
                    // tilemap_set_at_pixel takes the tile data (which includes index, flip, rotate, etc.)
                    // For a basic tile, we just need the index.
                    var _tile_data = tile_set_index(0, _random_tile_index); // Creates tiledata with index
                    tilemap_set_at_pixel(tilemap_id, _tile_data, _tile_world_x, _tile_world_y);
                }
            }
            
            // Mark this chunk as generated
            ds_map_add(generated_chunks_map, _chunk_key, true);
        }
    }
}

// Optional: Add logic here to despawn or clear tiles from chunks that are very far from the camera
// to save memory, but this is more complex and might not be needed initially.
