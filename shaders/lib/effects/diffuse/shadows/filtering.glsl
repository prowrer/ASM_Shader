const int shadowMapResolution = 1024; // Shadowmap resolution [256 512 1024 2048 4096 8192 16384]
const float sunPathRotation = -45;
const float shadowDistance = 120.0;

float getVisibility(in vec3 viewPos, in vec2 coord, in vec3 l)
{
    vec3 worldPos = viewToWorld(viewPos);
    vec3 shadowPos = worldToShadow(worldPos) * 0.5 + 0.5; // in screen space

    const int pcfSamples = 8;
    const int blockerSamples = 8;
    float bias = dot(normalize(cross(dFdx(viewPos), dFdy(viewPos))), l) * 0.001;

    // Average blocker
    float radius = 60.0 * (shadowMapResolution * 0.0009765625);
    float blockerResult = 0.0;
    int blockerCount = 0;
    for (int i = 0; i < blockerSamples; i++)
    {
        float ang = 2.4 * i + rand(coord) * M_PI2;
        vec2 offset = vec2(cos(ang), sin(ang));
        offset = offset * sqrt((i+rand(coord))/blockerSamples) * radius;
        offset /= shadowMapResolution;

        float sample = texture2D(shadowtex1, shadowPos.xy+offset).r;
        if (shadowPos.z - sample > bias)
        {
            blockerResult += sample;
            blockerCount++;
        }
    }
    // Early out if there was no blocker found
    if (blockerCount <= 0)
        return 1.0;
    blockerResult /= blockerCount;
    // Now, we calculate the penumbra
    radius = (shadowPos.z-blockerResult) * radius / blockerResult;


    // The PCF
    float result = 0.0;
    for (int i = 0; i < pcfSamples; i++)
    {
        float ang = 2.4 * i + rand(coord) * M_PI2;
        vec2 offset = vec2(cos(ang), sin(ang));
        offset = offset * sqrt((i+rand(coord))/pcfSamples) * radius;
        offset /= shadowMapResolution;

        result += step(shadowPos.z - texture2D(shadowtex1, shadowPos.xy+offset).r, bias);
    }
    
    return result / pcfSamples;
}