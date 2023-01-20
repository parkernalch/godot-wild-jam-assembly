shader_type canvas_item;
render_mode unshaded;

uniform float temperature_value;

uniform vec2 v_local_position = vec2(0.0);
varying vec2 v_normalized_screen_position;
uniform vec2 scroll;
uniform vec2 scroll2;
uniform sampler2D noiseTexture;
uniform sampler2D heatTexture;
uniform sampler2D coldTexture;
const float tau = 6.283185307179586;

void vertex() {
    vec2 v_clip_position = (PROJECTION_MATRIX * WORLD_MATRIX * vec4(v_local_position, 0.0, 1.0)).xy;
    v_normalized_screen_position = v_clip_position * 0.5 + vec2(0.5); // [-1.0, 1.0] -> [0.0, 1.0]
}

void fragment() {
    float noise = texture(TEXTURE, UV + scroll * TIME * sign(temperature_value)).x;
	float noise2 = texture(noiseTexture, UV + scroll2 * TIME * sign(temperature_value) * temperature_value).x;
	float energy = noise * noise2 - (1.0 - UV.y);

	vec4 heatColor = texture(heatTexture, vec2(energy));
	vec4 coldColor = texture(coldTexture, vec2(energy));
	
	vec4 color = temperature_value > 0.0 ? heatColor : coldColor;
	
	vec4 screenTexture = texture(SCREEN_TEXTURE, SCREEN_UV);
    
	COLOR.rgba *= color.rgba;
	
	COLOR.a *= .9-cos(UV.x*tau);
	COLOR.a *= 1.5-sin(UV.y);
	
	COLOR.a *= (abs(temperature_value) * 1.23) - (1.0 - UV.y);
	
//	COLOR.rgba *= screenTexture;

	
}