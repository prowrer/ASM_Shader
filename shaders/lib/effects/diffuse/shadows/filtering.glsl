const int shadowMapResolution = 1024;
const float sunPathRotation = -45;

float getVisibility(in vec3 viewPos, in vec2 coord, in vec3 l)
{
    vec3 worldPos = viewToWorld(viewPos);
    vec3 shadowPos = worldToShadow(worldPos) * 0.5 + 0.5; // in screen space

    const int pcfSamples = 8;
    const int blockerSamples = 8;
    const float bias = 0.00025;

    // Average blocker
    float radius = 60.0 * (shadowMapResolution * 0.0009765625);
    float origRadius = radius;
    float blockerResult = 0.0;
    int blockerCount = 0;
    for (int i = 0; i < blockerSamples; i++)
    {
        float ang = 2.4 * i + interleaved(gl_FragCoord.xy)*M_PI2;
        vec2 offset = vec2(cos(ang), sin(ang));
        offset = offset * sqrt((i + 0.5 + rand(coord)) / blockerSamples) * radius;
        offset /= shadowMapResolution;

        float sample = texture2D(shadowtex1, shadowPos.xy+offset).r;
        if (shadowPos.z - sample > bias)
        {
            blockerResult += sample;
            blockerCount++;
        }
    }
    blockerResult /= blockerCount;
    // Now, we calculate the penumbra
    radius = (shadowPos.z-blockerResult) * radius / blockerResult;

    // The PCF is simple due to performance reason
    float result = 0.0;
    for (int i = 0; i < pcfSamples; i++)
    {
        float ang = 2.4 * i + interleaved(gl_FragCoord.xy)*M_PI2;
        vec2 offset = vec2(cos(ang), sin(ang));
        offset = offset * sqrt((i + 0.5 + rand(coord)) / pcfSamples) * radius;
        offset /= shadowMapResolution;

        result += step(shadowPos.z - texture2D(shadowtex1, shadowPos.xy+offset).r, bias);
    }
    
    return result / pcfSamples;
}