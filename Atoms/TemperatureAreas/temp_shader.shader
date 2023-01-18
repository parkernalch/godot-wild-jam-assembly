shader_type canvas_item;
render_mode unshaded;

uniform float temperature_value;
uniform vec4 hotColor : hint_color;
uniform vec4 coldColor : hint_color;

uniform float heatAmplitude : hint_range(0.0, 0.15);
uniform float heatPeriod;
uniform float heatPhaseShift;
uniform float heatUpperLimit : hint_range(0.5, 10.0);

uniform sampler2D coldNormal : hint_normal;
uniform float coldFXStrength : hint_range(0.0, 1.0);

uniform vec2 v_local_position = vec2(0.0);
varying vec2 v_normalized_screen_position;
uniform vec2 scroll;
uniform vec2 scroll2;
uniform sampler2D noiseTexture;
uniform sampler2D colorTexture;
uniform sampler2D mask: hint_albedo;

void vertex() {
    vec2 v_clip_position = (PROJECTION_MATRIX * WORLD_MATRIX * vec4(v_local_position, 0.0, 1.0)).xy;
    v_normalized_screen_position = v_clip_position * 0.5 + vec2(0.5); // [-1.0, 1.0] -> [0.0, 1.0]
}

void fragment() {
//	float currentHot = clamp(temperature_value, 0.0, 1.0);
//	float currentCold = -clamp(temperature_value, -1.0, 0.0);
//	vec4 hotnessColor = (hotColor * currentHot);
//	vec4 coldnessColor = (coldColor * currentCold);
//	float effectStrength = coldFXStrength * currentCold;
//	vec2 modifiedUVHot = SCREEN_UV;
//	vec2 modifiedUVCold = SCREEN_UV;
//
//    modifiedUVHot.x -= heatAmplitude * sin(heatPeriod * (modifiedUVHot.y + heatPhaseShift) + TIME);
	
	// get screen uvs within current uv

//	vec2 normalizedSquareUV = SCREEN_UV);
    float noise = texture(TEXTURE, UV + scroll * TIME).x;
	float noise2 = texture(noiseTexture, UV + scroll2 * TIME).x;
	float energy = noise * noise2 - (1.0 - UV.y);
	vec4 color = texture(colorTexture, vec2(energy));
//    color.a *= sin(UV.x * 6.28 );
	vec2 pointOnLine = vec2(0.5, clamp(UV.y, .4, 2.2));
	float sdf = distance(UV, pointOnLine);

//	color.a *= UV.y;
//	color.a = 1.0-sdf;

//	if (sdf < .2) { color.a = sdf; }
//	color.a = 1.0-sdf;
	vec4 shader = texture(mask, UV + vec2(0, .2) * TIME).rgba;
	if (temperature_value > 0.0) {
	    COLOR.rgb = color.rgb;
	    COLOR.a = shader.r;
		COLOR.a *= UV.y * (temperature_value * 2.0);
		COLOR.a *= 1.0-cos(UV.x*6.23);
		COLOR.a *= energy*3.0;
	} else {
		COLOR.a = 0.0;
	}
	
	
//	COLOR = vec4(sdf,sdf,sdf,1);
//	vec2 distortedUV = SCREEN_UV;
//	distortedUV.x -= (((1.0 - energy) * heatAmplitude) *
//	 sin(heatPeriod * (energy - (TIME * 0.016  * heatPhaseShift)))) *
//	 clamp(1.0 - (energy * (10.0 - heatUpperLimit)), 0.0, 0.5);
//
//	COLOR = textureLod(SCREEN_TEXTURE, distortedUV, 0.0);
	// COLOR = vec4(1,1,1,.4);
//	COLOR = texture(SCREEN_TEXTURE, modifiedUVHot);
	
//	COLOR.rgb *= hotColor.rgb;

    // modifiedUVHot.x -= (((1.0 - modifiedUVHot.y) * heatAmplitude) *
	// 	sin(heatPeriod * (modifiedUVHot.y - (TIME * 0.016  * heatPhaseShift)))) *
	// 	clamp(1.0 - (modifiedUVHot.y * (10.0 - heatUpperLimit)), 0.0, 0.5) *
	// 	currentHot;
	
	// modifiedUVCold += (texture(coldNormal, UV).xy * effectStrength) - effectStrength * 0.5;
	// COLOR = texture(SCREEN_TEXTURE, (modifiedUVHot + modifiedUVCold) * 0.5);
    
    // COLOR.rgb += hotnessColor.rgb * hotnessColor.a;
	// COLOR.rgb += coldnessColor.rgb * coldnessColor.a; 
}