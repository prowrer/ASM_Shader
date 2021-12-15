#version 120

// This program will be mostly focused on volumetric stuff, except for light absorption in water
// All volumetric computation functions will be here. No need to make .glsl file since we're not using them in other programs

// Varyings
varying vec2 texcoord;

// Uniforms
uniform int frameCounter;

// Pre-processor constants
#include "/lib/constants.glsl"

// Sampling functions
#include "/lib/framebuffers.glsl"
#include "/lib/depthBuffer.glsl"

// Space transformation functions
#include "/lib/transforms.glsl"
#include "/lib/shadowTransforms.glsl"

// Randomness
#include "/lib/randomNumber/random.glsl"

void main()
{
    vec4 color = getColor(texcoord);
    float depth0 = getDepth(texcoord);
    vec3 position = screenToView(texcoord, depth0);
    vec3 viewDir = normalize(position);

    // Volumetric code
    {
        // Constants
        const float density = 0.01;
        const vec3 fogColor = vec3(0.73, 0.8, 0.82);
        const int volumetricSteps = 8;

        // Distance and transmittance
        float posLength = length(position);
        float transmittance = exp(-posLength * density);

        // Volumetric lighting / Godrays
        float visibility = 0.0;
        if (depth0 < 1.0)
        {
            for (int i = 0; i < volumetricSteps; i++)
            {
                vec3 marchedPos = viewDir * posLength * (i+interleaved(gl_FragCoord.xy)) / volumetricSteps;
                vec3 shadowPos = worldToShadow(viewToWorld(marchedPos)) * 0.5 + 0.5;

                visibility += step(shadowPos.z - texture2D(shadowtex1, shadowPos.xy).r, 1e-3);
            }
            visibility /= volumetricSteps;
        }
        else
            visibility = 1.0;
        transmittance = mix(1.0, transmittance, visibility); // visibility = 0, no light reached the camera

        color.rgb = color.rgb*transmittance + fogColor*(1.0 - transmittance)*20e3;
    }

    /* DRAWBUFFERS: 0 */
    gl_FragData[0] = color;
}