// This file contains code to compute screen space ray tracing effects:
// reflections, global illumination

vec3 ssr_ssgi(vec2 coord, vec3 v, vec3 p, vec3 n, Material m, vec3 color)
{
    const int samples = 1;
    #ifdef MULTI_BOUNCE
        const int bounces = 4;
    #else
        const int bounces = 1;
    #endif
    const int steps = 30;
    const float stepSize = 0.1;

    vec3 result = vec3(0.0);
    float averagedRayDistance = 0.0;
    float sum_w = 0.0;
    for (int s = 0; s < samples; s++)
    {
        vec3 prevDir = v;
        Material hitMat = m;
        vec3 hitPos = p;
        vec3 hitNorm = n;
        vec2 hitCoord = coord;
        vec3 energy = vec3(1.0);
        for (int b = 0; b < bounces; b++)
        {
            float specChance = min(hitMat.f0, 229.0/255.0);
            vec3 origAlbedo = hitMat.albedo;
            hitMat.albedo = min(hitMat.albedo, 1.0 - specChance);
            float diffChance = dot(hitMat.albedo, vec3(0.333));
            float sum = diffChance+specChance;
            specChance /= sum;
            diffChance /= sum;
            #ifdef russianRoulette
                bool roulette = interleaved(gl_FragCoord.xy) < specChance; // true = specular, false = diffuse
                roulette = roulette ? roulette : hitMat.is_metal;
            #else
                bool roulette = true;
            #endif
            energy *= roulette ? (hitMat.is_metal ? origAlbedo : vec3(1)) : hitMat.albedo;
            vec3 r = ImportanceSampleGGX(hitNorm, randV2(coord), hitMat.roughness);
            r = roulette ? reflect(prevDir, r) : ImportanceSampleCosine(hitNorm, randV2(coord)); // don't reflect when diffuse because it'll go beneath the surface

            // Intersection
            vec3 origin = hitPos;
            bool foundHit = intersect(hitPos, hitCoord, r, steps, stepSize);

            if (foundHit)
            {
                // Calculate BRDF
                vec3 weight;
                float NL = max(1e-5, dot(hitNorm, r));
                if (roulette)
                {
                    vec3 H = normalize(-prevDir + r);
                    float LH = max(1e-5, dot(r, H));
                    float NV = max(1e-5, dot(hitNorm, -prevDir));

                    // Part of importance sampling
                    float absVH = abs(dot(-prevDir, H));
                    float absNV = abs(dot(hitNorm, -prevDir));
                    float absNH = abs(dot(hitNorm, H));
                    float denominator = absNV * absNH;

                    vec3 metalProperties[2]; getPredefinedMetal(hitMat.f0, metalProperties);

                    vec3 F = fresnelFunction(origAlbedo, LH, metalProperties[0], metalProperties[1], hitMat.f0);
                    float G = G_SmithGGX(NV, NL, hitMat.roughness);
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

                energy *= weight;

                vec3 hitColor = getColor(hitCoord).rgb;
                result += energy * hitColor;
                if (b == 0)
                    averagedRayDistance += length(hitPos - p);

                // Update stuff for next bounce
                hitMat = getMaterialProperties(hitCoord);
                prevDir = normalize(hitPos - origin);
                hitNorm = getNormals(hitCoord).rgb;
            }
            else
                break; // break the bounce loop since we got nothing
        }
    }
    result /= samples;
    result = max(result, 0.0);
    averagedRayDistance /= samples;
    averagedRayDistance = max(averagedRayDistance, 0.0);

    // Thanks to Samuel in ShaderLABS discord server for helping me with specular (hit) reprojection
    #ifdef doTemporal
        //return result;
        vec2 reprojected_coord;
        if (m.roughness < 0.4)
            p += v*averagedRayDistance;
        return temporal(result, colortex4, p, 1.0 - frameTime);
    #else
        return result;
    #endif
}