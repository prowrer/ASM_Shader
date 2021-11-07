#version 120

varying vec2 texcoord;

uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;

vec2 ScreenResolution = vec2(viewWidth, viewHeight);

#include "/lib/framebuffers.glsl"
#include "/lib/depthBuffer.glsl"
#include "/lib/constants.glsl"
#include "/lib/settings.glsl"

#include "/lib/randomNumber/random.glsl"

#include "/lib/materials.glsl"

#include "/lib/transforms.glsl"

#include "/lib/filtering/spatial.glsl"

void main()
{
    vec3 normals = getNormals(texcoord).rgb;
    vec3 position = screenToView(texcoord, getDepth(texcoord));
    Material material = getMaterialProperties(texcoord);

    vec4 color = getColor(texcoord);

    vec4 ssrt = vec4(0.0);
    #ifdef doSSRT
        ssrt = getSSRT(texcoord);
        #ifdef doTemporal
            ssrt = atrous(texcoord, material.albedo, normals, position, material);
        #endif

        color.rgb = color.rgb*(1.0-material.metalness) + max(ssrt.rgb, 0.0);
        //color.rgb = ssrt.rgb;
    #endif

    /* DRAWBUFFERS: 03 */
    gl_FragData[0] = color;
    gl_FragData[1] = ssrt;
}