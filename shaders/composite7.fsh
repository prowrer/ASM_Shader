#version 130

#define doTemporal

varying vec2 texcoord;

uniform sampler2D depthtex0;

// For temporal filtering to work, we need to disable clearing for colortex8
// also set the format to be the same as colortex0
/*
const int colortex8Format = RGBA16F;
const bool colortex8Clear = false;
*/

uniform vec3 cameraPosition;
uniform int frameCounter;
uniform float frameTime;

uniform float viewWidth;
uniform float viewHeight;
vec2 ScreenResolution = vec2(viewWidth, viewHeight);

#include "/lib/framebuffers.glsl"

#include "/lib/constants.glsl"

#include "/lib/materials.glsl"

#include "/lib/transforms.glsl"
#include "/lib/filtering/temporal.glsl"


void main()
{
    float depth = texture2D(depthtex0, texcoord).r;
    vec3 position = screenToView(texcoord, depth);
    vec3 normals = getNormals(texcoord).rgb;
    vec2 prevTexcoord = getPrevCoord(position);

    Material mat = getMaterialProperties(texcoord);
    vec4 color = max(getColor(texcoord), 1e-5);
    vec4 prevColor = getPreviousColor(prevTexcoord);
    prevColor.rgb = max(prevColor.rgb, 1e-5);

    #ifdef doTemporal
        color.rgb = TAA(color.rgb, texcoord, position, 0.9);
    #else
        if (length(cameraPosition - previousCameraPosition) <= 1e-5)
        {
            prevColor.rgb += color.rgb;
            prevColor.a++;

            color.rgb = prevColor.rgb / prevColor.a;
        }
        else
            prevColor = vec4(0);
    #endif


    /* DRAWBUFFERS: 081 */
    gl_FragData[0] = color;
    #ifdef doTemporal
        gl_FragData[1] = vec4(color.rgb, depth);
    #else
        gl_FragData[1] = prevColor;
    #endif
}