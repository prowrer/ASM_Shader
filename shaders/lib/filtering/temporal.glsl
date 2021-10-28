uniform vec3 previousCameraPosition;

uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

vec2 getPrevCoord(in vec3 viewPos)
{
	vec4 worldSpace = gbufferModelViewInverse * vec4(viewPos, 1.0) + vec4(cameraPosition - previousCameraPosition, 0.0);
	worldSpace = gbufferPreviousModelView * worldSpace;
	return nvecw(gbufferPreviousProjection * worldSpace).xy * 0.5 + 0.5;
}

vec3 temporal(vec3 currentColor, sampler2D previousBuffer, vec3 p, float strength)
{
	vec2 prevTexcoord = getPrevCoord(p);
	vec3 prevColor = texture2D(previousBuffer, prevTexcoord).rgb;

	float weights = strength;
	weights *= float(prevTexcoord.x < 1.0 && prevTexcoord.x > 0.0 && prevTexcoord.y < 1.0 && prevTexcoord.y > 0.0);
	currentColor = mix(currentColor, prevColor, weights);

	return currentColor;
}
vec3 TAA(vec3 currentColor, in sampler2D currentBuffer, sampler2D previousBuffer, vec2 coord, vec3 p, float strength)
{
	const float d_phi = 0.001;
	const float n_phi = 0.01;

	vec2 prevTexcoord = getPrevCoord(p);
	vec3 prevColor = texture2D(previousBuffer, prevTexcoord).rgb;

	vec3 c0 = texture2D(currentBuffer, coord + vec2(1, 0)/ScreenResolution).rgb;
	vec3 c1 = texture2D(currentBuffer, coord + vec2(0, 1)/ScreenResolution).rgb;
	vec3 c2 = texture2D(currentBuffer, coord - vec2(1, 0)/ScreenResolution).rgb;
	vec3 c3 = texture2D(currentBuffer, coord - vec2(0, 1)/ScreenResolution).rgb;

	// Neighbourhood clamping
	vec3 minC = min(c0, min(c1, min(c2, c3)));
	vec3 maxC = max(c0, max(c1, max(c2, c3)));
	prevColor = clamp(prevColor, minC, maxC);

	float weights = strength;
	weights *= float(prevTexcoord.x < 1.0 && prevTexcoord.x > 0.0 && prevTexcoord.y < 1.0 && prevTexcoord.y > 0.0);
	currentColor = mix(currentColor, prevColor, weights);

	return currentColor;
}