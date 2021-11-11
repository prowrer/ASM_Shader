#version 130
#include "/lib/colors.glsl"

varying vec2 texcoord;
uniform float viewHeight;
uniform float viewWidth;
vec2 step_ = 1.0 / vec2(viewWidth, viewHeight);

#include "/lib/constants.glsl"

#include "/lib/framebuffers.glsl"

float getSaturationBasedExposure(float aperture, float shutterSpeed, float iso)
{
    float l_max = (7800.0f / 65.0f) * aperture*aperture / (iso * shutterSpeed);
    return 1.0f / l_max;
}

void main()
{
    vec4 color = getColor(texcoord);

    // Auto exposure
    vec3 color_mip = max(textureLod(colortex0, texcoord, 1000.0).rgb, 0.0);
    float avgBrightness = max(max(max(color_mip.r, color_mip.g), color_mip.b), 0.1);
    color *= getSaturationBasedExposure(16.0, 1.0/100.0, 100.0);

    color.rgb = aces_approx(color.rgb);
    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

    gl_FragColor = color;
}