uniform vec3 previousCameraPosition;

uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

vec2 getPrevCoord(in vec3 viewPos)
{
	vec3 worldSpace = nvecw(gbufferModelViewInverse * vec4(viewPos, 1.0) + vec4(cameraPosition - previousCameraPosition, 0.0));
	worldSpace = nvecw(gbufferPreviousModelView * vec4(worldSpace, 1.0));
	return nvecw(gbufferPreviousProjection * vec4(worldSpace, 1.0)).xy * 0.5 + 0.5;
}

vec3 TAA(in vec3 currentColor, in vec2 coord, in vec3 p, in float strength)
{
	const float d_phi = 0.001;
	const float n_phi = 0.01;

	vec2 prevTexcoord = getPrevCoord(p);
	vec3 prevColor = getPreviousColor(prevTexcoord).rgb;

	vec3 c0 = getColor(coord + vec2(1, 0)/ScreenResolution).rgb;
	vec3 c1 = getColor(coord + vec2(0, 1)/ScreenResolution).rgb;
	vec3 c2 = getColor(coord - vec2(1, 0)/ScreenResolution).rgb;
	vec3 c3 = getColor(coord - vec2(0, 1)/ScreenResolution).rgb;

	// Neighbourhood clamping
	vec3 minC = min(c0, min(c1, min(c2, c3)));
	vec3 maxC = max(c0, max(c1, max(c2, c3)));
	prevColor = clamp(prevColor, minC, maxC);

	float weights = strength;
	weights *= float(prevTexcoord.x < 1.0 && prevTexcoord.x > 0.0 && prevTexcoord.y < 1.0 && prevTexcoord.y > 0.0);
	currentColor = mix(currentColor, prevColor, weights);

	return currentColor;
}