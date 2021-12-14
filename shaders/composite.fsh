#version 130

varying vec2 texcoord;

uniform int frameCounter;
uniform float frameTime;
uniform vec3 cameraPosition;

uniform float viewHeight;
uniform float viewWidth;
vec2 ScreenResolution = vec2(viewWidth, viewHeight);

/*
const int colortex3Format = RGBA16F;
const int colortex4Format = RGBA16F;
const bool colortex4Clear = false;
*/
// We're going to need to store previous depthtex value for deghosting. We're going to use colortex5.r for that
// we're going to set it's format to R16... hopefully the loss of precision is not too bad
// and also disable clearing
/*
const int colortex5Format = R16;
const bool colortex5Clear = false;
*/

#include "/lib/constants.glsl"
#include "/lib/randomNumber/random.glsl"
#include "/lib/settings.glsl"

#include "/lib/framebuffers.glsl"
#include "/lib/depthBuffer.glsl"

#include "/lib/transforms.glsl"

#include "/lib/materials.glsl"
#include "/lib/effects/brdf.glsl"

#include "/lib/filtering/temporal.glsl"

#include "/lib/sampling.glsl"

#include "/lib/effects/ssrt/intersection.glsl"
#include "/lib/effects/ssrt/rtEffects.glsl"


void main()
{
    float depth0 = getDepth(texcoord); // no exclusion
    float depth1 = getDepth(texcoord, 1); // excluded translucent (ie. water, stained glass) and particles
    vec3 position = screenToView(texcoord, depth0);
    vec3 viewDir = normalize(position);

    vec4 normals = getNormals(texcoord);
    vec4 color = getColor(texcoord);
    Material material = getMaterialProperties(texcoord);

    // Water absorption
    if (depth1 > depth0 && depth1 < 1.0) // 0-1 = close to far, so depth1 would have a higher value when there is water (or other stuff excluded in depth1, but idc)
    {
        vec3 fogColor = vec3(0.4, 0.07, 0.03);//vec3(0.1, 0.25, 0.4);

        float fogDist = length(screenToView(texcoord, depth1) - position);

        vec3 absorption = exp(-fogColor * fogDist);

        color.rgb *= absorption;
    }

    vec4 ssrt = vec4(0);
    #ifdef doSSRT
        if (depth0 < 1.0)
            ssrt.rgb = ssr_ssgi(texcoord, viewDir, position, normals.xyz, material, color.rgb);
    #endif

    /* DRAWBUFFERS: 0345 */
    gl_FragData[0] = color;
    gl_FragData[1] = ssrt;
    gl_FragData[2] = ssrt;
    gl_FragData[3] = vec4(exp(-depth0), 0.0, 0.0, 0.0);
}