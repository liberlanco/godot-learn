shader_type canvas_item;

const vec3 TO_REPLACE = vec3(1, 0.749, 0.212);   // bow
const vec3 NEED_COLOR = vec3(0.5, 0.1, 0.4);
uniform vec3 replacement_color:source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 diff = (COLOR.rgb - TO_REPLACE);
	float diff_len = length(diff);
	float keep_mask = step(0.01, diff_len);
	float change_mask = 1.0 - keep_mask;
	
	vec3 keep_color = keep_mask * COLOR.rgb;
	vec3 change_color = change_mask * replacement_color;


	//COLOR.rgb = vec3(change_mask);
	COLOR.rgb = keep_color + change_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
