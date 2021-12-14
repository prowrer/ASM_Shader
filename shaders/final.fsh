#version 130
#include "/lib/colors.glsl"

varying vec2 texcoord;
uniform float viewHeight;
uniform float viewWidth;
uniform int frameCounter;
vec2 ScreenResolution = vec2(viewWidth, viewHeight);

// We need to enable mipmapping for colortex0 for use in bloom
/*
const bool colortex0MipmapEnabled = true;
*/

#include "/lib/constants.glsl"
#include "/lib/randomNumber/random.glsl"
#include "/lib/settings.glsl"

#include "/lib/framebuffers.glsl"

float getSaturationBasedExposure(float aperture, float shutterSpeed, float iso)
{
    float l_max = (7800.0f / 65.0f) * aperture*aperture / (iso * shutterSpeed);
    return 1.0f / l_max;
}
float getExposureFromSceneAverage()
{
    // Got some of the equations/code from:
    //https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf

    const int lodLevel = 10;
    // How many pixels have been reduced based on lodLevel? That would be 2^lodLevel
    int kernelSize = 1 + int(exp2(lodLevel)); // we add 1 to that because when the level is 0, the kernelSize is only 1

    float avgLogLum = 0.0;
    int samples = 0;
    for (int x = 0; x < viewWidth; x += kernelSize)
        for (int y = 0; y < viewHeight; y += kernelSize)
        {
            vec2 sampleCoord = vec2(x, y) / ScreenResolution;
            avgLogLum += luminance(textureLod(colortex0, sampleCoord, lodLevel).rgb);
            samples++;
        }
    avgLogLum /= samples;

    float EV100 = log2(avgLogLum * 100.0 / 12.5);

    return 1.0 / (1.2 * exp2(EV100));
}
vec3 bloom(in vec2 coord, in vec3 color)
{
    const int samples = 8;
    const float res_percent = 0.125;
    const float intensity = 0.5;

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
    vec4 color = getColor(texcoord);
    color.rgb = bloom(texcoord, color.rgb);

    // Auto exposure
    color.rgb *= getExposureFromSceneAverage();
    //color.rgb *= getSaturationBasedExposure(16.0, 1.0/100.0, 1000.0);

    color.rgb = aces_approx(color.rgb);
    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

    /* DRAWBUFFERS: 0 */
    gl_FragData[0] = color;
}