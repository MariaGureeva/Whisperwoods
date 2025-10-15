shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.01, 0.0); 
uniform float fog_opacity = 0.5;            

void fragment() {
  
    vec2 uv = UV + TIME * scroll_speed;

 
    vec4 tex = texture(TEXTURE, uv);

    COLOR.rgb = tex.rgb;
    COLOR.a = tex.a * fog_opacity;
}
