#version 120

varying vec2 texcoord;

uniform vec3 shadowLightPosition;
uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;
vec2 ScreenResolution = vec2(viewWidth, viewHeight);

/*
const int colortex0Format = RGBA16F;
const bool colortex0MipmapEnabled = true;
const float ambientOcclusionLevel = 0.0;
*/

#include "/lib/constants.glsl"
#include "/lib/settings.glsl"
#include "/lib/randomNumber/random.glsl"
#include "/lib/math/approximates.glsl"

#include "/lib/framebuffers.glsl"
#include "/lib/depthBuffer.glsl"

#include "/lib/materials.glsl"
#include "/lib/effects/brdf.glsl"

#include "/lib/transforms.glsl"
#include "/lib/shadowTransforms.glsl"

#include "/lib/effects/ambientOcclusion/ao.glsl"
#include "/lib/effects/diffuse/shadows/filtering.glsl"


void main()
{
    float depth0 = getDepth(texcoord); // no exclusion
    float depth1 = getDepth(texcoord, 1); // excluded translucent (ie. water, stained glass) and particles

    vec3 position = screenToView(texcoord, depth1);
    vec3 viewDir = normalize(position);
    vec3 sunDir = normalize(shadowLightPosition);

    vec4 normals = getNormals(texcoord);
    vec4 color = getColor(texcoord);

    Material surface_mat = getMaterialProperties(texcoord);
    
    if (depth0 < 1.0)
    {
        // Diffuse/Shadows
        float shadows = getVisibility(position, texcoord, sunDir);
        float diffuse = orenNayar(viewDir, normals.xyz, sunDir, surface_mat.roughness)*shadows;

        // Specular
        vec3 specular = cookTorrance(viewDir, normals.xyz, sunDir, surface_mat.albedo, surface_mat.roughness, surface_mat.f0);

        // Combine into direct lighting
        #ifdef doSSRT
            #ifdef russianRoulette
                diffuse = diffuse * (1.0 - surface_mat.metalness);
            #else
                diffuse = min(diffuse+ambientLight*gtao(texcoord, normals.xyz, position, viewDir), 1.0) * (1.0 - surface_mat.metalness);
            #endif
        #else
            diffuse = min(diffuse+ambientLight*gtao(texcoord, normals.xyz, position, viewDir), 1.0) * (1.0 - surface_mat.metalness);
        #endif
        diffuse *= 120e3; // apply accurate sun lux value
        specular *= 120e3; // apply accurate sun lux value
        color.rgb = diffuse*color.rgb + specular * shadows * max(0.0, dot(normals.xyz, sunDir));

        // Apply emissive
        float lux = surface_mat.emission;
        lux = lux <= 0.996078431 ? lux / 0.996078431 * 5800.0 : 0.0;
        color.rgb += lux * surface_mat.albedo.rgb; // since lights are additive, simply add
    }
    else
        color.rgb *= 20e3; // apply "accurate" sky lux value

    /* DRAWBUFFERS: 0 */
    gl_FragData[0] = color;
}