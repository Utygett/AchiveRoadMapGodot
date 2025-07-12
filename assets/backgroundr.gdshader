shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(0.6, 0.6, 0.6, 1.0);
uniform vec4 bg_color : source_color = vec4(0.3, 0.3, 0.3, 1.0);
uniform float cell_size = 50.0;

void fragment() {
    // Используем TEXTURE_PIXEL_SIZE для получения размера
    vec2 pixel_size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 grid_uv = UV * pixel_size / cell_size;
    vec2 grid_pos = fract(grid_uv);
    
    if (grid_pos.x < 0.01 || grid_pos.y < 0.01) {
        COLOR = grid_color;
    } else {
        COLOR = bg_color;
    }
}