// glow.gdshader
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float intensity : hint_range(0.0, 3.0) = 1.5;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    // Só brilha nos pixels que têm cor (alpha > 0)
    if (tex.a > 0.1) {
        COLOR = vec4(tex.rgb + glow_color.rgb * intensity * tex.a, tex.a);
    } else {
        COLOR = tex;
    }
}