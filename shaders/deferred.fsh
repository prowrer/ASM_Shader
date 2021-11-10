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

#include "/lib/effects/specular/highlight.glsl"

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
        // Calculate shadows
        float visibility = getVisibility(position, texcoord, sunDir);
        visibility = min(visibility, orenNayar(viewDir, normals.xyz, sunDir, surface_mat.roughness));

        // Calculate specular highlight
        color.rgb = specularHighlight(viewDir, sunDir, normals.xyz, surface_mat, visibility, color.rgb);
        #ifdef russianRoulette // change ambient light is zero when we're doing global illumination
            #ifdef doSSRT
                color *= max(visibility - surface_mat.metalness, 0.0);
            #else
                color *= min(visibility + surface_mat.metalness, 1.0);
            #endif
        #else
            #ifdef doSSRT
                color *= max(visibility + ambientLight*gtao(texcoord, normals.rgb, position, viewDir) - surface_mat.metalness, 0.0);
            #else
                color *= min(visibility + ambientLight*gtao(texcoord, normals.rgb, position, viewDir) + surface_mat.metalness, 1.0);
            #endif
        #endif

        // Apply emissive
        float luminosity = surface_mat.emission;
        luminosity = luminosity <= 0.996078431 ? luminosity / 0.996078431 * 6.0 : 0.0;
        color.rgb += luminosity * surface_mat.albedo.rgb; // since lights are additive, simply add
    }

    /* DRAWBUFFERS: 0 */
    gl_FragData[0] = color;
}