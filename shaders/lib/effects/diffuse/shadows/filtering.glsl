const int shadowMapResolution = 2048;
const float sunPathRotation = -45;

float getVisibility(in vec3 viewPos, in vec2 coord, in vec3 l)
{
    vec3 worldPos = viewToWorld(viewPos);
    vec3 shadowPos = worldToShadow(worldPos) * 0.5 + 0.5; // in screen space

    const int pcfSamples = 8;
    const int blockerSamples = 8;
    const float bias = 0.001;

    // Average blocker
    float radius = 120.0 * (shadowMapResolution * 0.0009765625);
    float origRadius = radius;
    radius *= shadowPos.z;
    float blockerResult = 0.0;
    int blockerCount = 0;
    for (int i = 0; i < blockerSamples; i++)
    {
        float ang = 2.4 * i + rand(coord) * M_PI2;
        vec2 offset = vec2(cos(ang), sin(ang));
        offset = offset * sqrt((i+interleaved(gl_FragCoord.xy))/blockerSamples) * radius;
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
    radius = (shadowPos.z-blockerResult) * origRadius / blockerResult;


    // The PCF
    float result = 0.0;
    for (int i = 0; i < pcfSamples; i++)
    {
        float ang = 2.4 * i + rand(coord) * M_PI2;
        vec2 offset = vec2(cos(ang), sin(ang));
        offset = offset * sqrt((i+interleaved(gl_FragCoord.xy))/pcfSamples) * radius;
        offset /= shadowMapResolution;

        result += step(shadowPos.z - texture2D(shadowtex1, shadowPos.xy+offset).r, bias);
    }
    
    return result / pcfSamples;
}