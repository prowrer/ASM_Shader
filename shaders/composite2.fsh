#version 130

varying vec2 texcoord;

uniform sampler2D colortex0;

uniform int frameCounter;

uniform float viewHeight;

/*
const bool colortex0MipmapEnabled = true;
*/

#include "/lib/constants.glsl"
#include "/lib/randomNumber/random.glsl"

vec3 bloom(in vec2 coord, in vec3 color)
{
    const int samples = 4;
    const float res_percent = 0.125;
    const float intensity = 0.25;

    float lod = 1.0 / (floor(viewHeight * res_percent) / viewHeight);

    vec3 result = vec3(0.0);
    for (int i = 0; i < samples; i++)
    {
        vec3 sample = max(textureLod(colortex0, coord, ((i+interleaved(gl_FragCoord.xy))/samples) * lod).rgb, 0.0);

        result += max(sample * intensity, 0.0);
    }
    
    return color + max(result / samples, 0.0);
}

void main()
{
    vec4 color = max(texture2D(colortex0, texcoord), 0.0);
    color.rgb = max(bloom(texcoord, color.rgb), 0.0);

    /* DRAWBUFFERS: 0 */
    gl_FragData[0] = color;
}