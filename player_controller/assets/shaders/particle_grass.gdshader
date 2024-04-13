shader_type particles;

uniform float instance_rows = 200;
uniform float instance_rot_randomize = 5;

uniform float instance_spacing = 0.125;
uniform float instance_scale_x = 1.0;
uniform	float instance_scale_y = 1.0;
uniform float instance_scale_z = 1.0;
uniform float instance_scale_randomize = 1.0;
uniform float instance_pos_randomize : hint_range(0.0, 50.0) =  30;
uniform float instance_scale_min = 1;
uniform float instance_scale_max = 1;
uniform float _coverage_altitude = 10.0;
uniform float _coverage_range = 200.0;
uniform float _slope_coverage = 0.25;
uniform float max_height = 40;
uniform float min_height = 5;

uniform sampler2D grass_map;
uniform vec2 grass_offset;

uniform sampler2D map_heightmap;
uniform bool instance_orient_to_normal = false;
uniform float instance_orientation_influence : hint_range(0.0, 10.0) = 1.0;
uniform float __terrain_amplitude = 24.0;
uniform vec2 map_heightmap_size = vec2(129.0, 129.0);

uniform float clumping_strength : hint_range(0.0, 100.0) = 20.0;
uniform sampler2D map_clumpmap;


float get_clumps(vec2 pos) {
	pos -= 0.5 * map_heightmap_size;
	pos /= map_heightmap_size;	
	return 24.0 * texture(map_clumpmap, pos).r;
}


void start() {
	// get position
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, instance_rows);
	pos.z = (pos.z - pos.x) / instance_rows;
	
	// center the emitter
	pos.x -= instance_rows * 0.5;
	pos.z -= instance_rows * 0.5;

	
	// apply instance spacing
	pos *= instance_spacing;
	
	// center on position of emitter
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], instance_spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], instance_spacing);
	
	// add noise 
	vec3 noise = texture(map_heightmap, pos.xz * 0.1).rgb;
	pos.x += noise.z * instance_spacing * instance_pos_randomize;
	pos.z -= noise.x * instance_spacing * instance_pos_randomize;


	// rotate transform
	vec3 tex_scale = vec3(1.0) ;

	vec3 base_scale = vec3(mix(instance_scale_min, instance_scale_max, noise.x)*instance_scale_x,mix(instance_scale_min, instance_scale_max, noise.y)*instance_scale_y,mix(instance_scale_min, instance_scale_max, noise.z)*instance_scale_z );
	base_scale *= base_scale*instance_scale_randomize;
	base_scale = sign(base_scale) * max(abs(base_scale), 0.1);
	
	// update transform
	pos.x += cos( noise.x * instance_pos_randomize) * base_scale.x  ;
	pos.z += sin( noise.z * instance_pos_randomize) * base_scale.z ; 
	
	pos.y = 1.0;
	float g_x = pos.x + grass_offset.x;
	float g_y = pos.z + grass_offset.y;
	
	float b_val = texture(grass_map, vec2(g_x / 64.0 , g_y / 64.0)).b;
	
	if (b_val > 0.5) {
		pos.y = -10.0;
	}
	
	
	
	
	TRANSFORM[0].xyz = vec3(0.0);
	TRANSFORM[1].xyz = vec3(0.0);
	TRANSFORM[2].xyz = vec3(0.0);
	
	// finalize transform positioning and scaling including randomizations	
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
	
	TRANSFORM[0][0] = cos(noise.x * instance_rot_randomize) * base_scale.x;
	TRANSFORM[0][2] = -sin(noise.x * instance_rot_randomize) * base_scale.x;
	TRANSFORM[2][0] = sin(noise.z * instance_rot_randomize) * base_scale.z;
	TRANSFORM[2][2] = cos(noise.z * instance_rot_randomize) * base_scale.z;
	
	TRANSFORM[0][0]  = base_scale.x;
	TRANSFORM[1][1] =  base_scale.y;
	TRANSFORM[2][2]  = base_scale.z;

}