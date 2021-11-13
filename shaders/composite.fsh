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
    vec3 position = screenToView(texcoord, depth0);
    vec3 viewDir = normalize(position);

    vec4 normals = getNormals(texcoord);
    vec4 color = getColor(texcoord);
    Material material = getMaterialProperties(texcoord);

    vec4 ssrt = vec4(0);
    #ifdef doSSRT
        if (depth0 < 1.0)
            ssrt.rgb = ssr_ssgi(texcoord, viewDir, position, normals.xyz, material, color.rgb);
    #endif

    /* DRAWBUFFERS: 0234 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(material.albedo, depth0);
    gl_FragData[2] = ssrt;
    gl_FragData[3] = ssrt;
}