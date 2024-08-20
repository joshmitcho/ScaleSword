shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 paper_sample = texture(TEXTURE, UV);
	vec4 screen_sample = texture(screen_texture, SCREEN_UV);
	float screen_luminance = (screen_sample.r + screen_sample.g + screen_sample.b) / 3.0;
	screen_luminance = smoothstep(0.05, 0.7, screen_luminance);
	COLOR = mix(screen_sample, paper_sample, screen_luminance/2.0);
}
