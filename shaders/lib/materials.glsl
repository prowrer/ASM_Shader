struct Material
{
	vec3 albedo;
	float avgAlbedo;
	bool is_metal;
	float metalness;
	float f0;
	float roughness;
	float emission;
};
Material getMaterialProperties(in vec2 coord)
{
	vec4 spectex = getSpecular(coord);

	Material mat;
	mat.albedo = getAlbedo(coord);
	mat.avgAlbedo = dot(mat.albedo, vec3(0.333));
	mat.is_metal = (spectex.y * 255.0 > 229.5);
	mat.metalness = mat.is_metal ? 1.0 : 0.0;
	mat.f0 = spectex.y;
	mat.roughness = 1.0 - spectex.x;
	mat.roughness *= mat.roughness;
	mat.emission = spectex.a;

	return mat;
}