// This file contains code to compute screen space ray tracing effects:
// reflections, global illumination

vec3 ssr_ssgi(vec2 coord, vec3 v, vec3 p, vec3 n, Material m, vec3 color)
{
    const int samples = 1;
    const int steps = 30;
    const float stepSize = 1.0;

    vec3 result = vec3(0.0);
    float averagedRayDistance = 0.0;
    float sum_w = 0.0;
    for (int s = 0; s < samples; s++)
    {
        
        float specChance = min(m.f0, 229.0/255.0);
        float specular = specChance;
        vec3 origAlbedo = m.albedo;
        m.albedo = min(m.albedo, 1.0 - specChance);
        specChance = dot(specChance, 0.333);
        float diffChance = dot(m.albedo, vec3(0.333));
        float sum = diffChance+specChance;
        specChance /= sum;
        diffChance /= sum;
        #ifdef russianRoulette
            bool roulette = interleaved(gl_FragCoord.xy) < specChance; // true = specular, false = diffuse
            roulette = roulette ? roulette : m.is_metal;
        #else
            bool roulette = true;
        #endif
        // Initialize necessary stuff
        vec3 energy = roulette ? (m.is_metal ? origAlbedo : vec3(1)) : m.albedo;
        vec3 r = roulette ? ImportanceSampleGGX(n, randV2(coord), m.roughness) : ImportanceSampleCosine(n, randV2(coord));
        r = roulette ? reflect(v, r) : r; // don't reflect when diffuse because it'll go beneath the surface

        // Intersection
        vec3 hitPos = p;
        vec2 hitCoord = coord;
        bool foundHit = intersect(hitPos, hitCoord, r, n, steps, stepSize);

        if (foundHit)
        {
            // Calculate BRDF
            vec3 weight;
            float NL = max(1e-5, dot(n, r));
            if (roulette)
            {
                vec3 H = normalize(-v + r);
                float LH = max(1e-5, dot(r, H));
                float NV = max(1e-5, dot(n, -v));

                // Part of importance sampling
                float absVH = abs(dot(-v, H));
                float absNV = abs(dot(n, -v));
                float absNH = abs(dot(n, H));
                float denominator = absNV * absNH;

                vec3 metalProperties[2]; getPredefinedMetal(m.f0, metalProperties);

                vec3 F = fresnelFunction(origAlbedo, LH, metalProperties[0], metalProperties[1], m.f0);
                float G = G_SmithGGX(NV, NL, m.roughness);
                #ifdef russianRoulette
                    weight = F*G*absVH / denominator / specChance;
                #else
                    weight = F*G*absVH / denominator;
                #endif
            }
            else
                #ifdef russianRoulette
                    weight = vec3(1.0 / diffChance);
                #else
                    weight = vec3(1.0);
                #endif

            vec3 hitColor = getColor(hitCoord).rgb;
            energy *= hitColor*weight;

            result += energy;
            averagedRayDistance += length(hitPos - p);
            sum_w++;
        }
    }
    result /= sum_w;
    result = max(result, 0.0);
    averagedRayDistance /= sum_w;
    averagedRayDistance = max(averagedRayDistance, 0.0);

    // Thanks to Samuel in ShaderLABS discord server for helping me with specular (hit) reprojection
    vec2 reprojected_coord;
    if (m.roughness < 0.4)
        p += v*averagedRayDistance;
    return result;//temporal(result, colortex4, p, 1.0);
}