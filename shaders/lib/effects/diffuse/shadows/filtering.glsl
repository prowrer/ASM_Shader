const int shadowMapResolution = 1024;
const float sunPathRotation = -45;

float getVisibility(in vec3 viewPos, in vec2 coord, in vec3 l)
{
    vec3 worldPos = viewToWorld(viewPos);
    vec3 shadowPos = worldToShadow(worldPos) * 0.5 + 0.5; // in screen space

    const int pcfSamples = 16;
    const int blockerSamples = 4; // sample count is actually squared

    // Average blocker
    float radius = 100.0;
    float origRadius = radius;
    float blockerResult = 0.0;
    for (int x = 0; x < blockerSamples; x++)
        for (int y = 0; y < blockerSamples; y++)
        {
            vec2 offset = (vec2(x, y)+randV2(coord)) / blockerSamples;
            offset = offset * 2.0 - 1.0; // [-1, 1] range
            offset = offset * radius / shadowMapResolution;

            blockerResult += texture2D(shadowtex1, shadowPos.xy+offset).r;
        }
    blockerResult /= blockerSamples*blockerSamples;
    // Now, we calculate the penumbra
    radius = (shadowPos.z-blockerResult) * origRadius / blockerResult;
    radius = max(radius, 1.0); // looks bad without blur

    // The PCF is simple due to performance reason
    float result = 0.0;
    for (int i = 0; i < pcfSamples; i++)
    {
        vec2 offset = randV2(coord) * 2.0 - 1.0;
        offset = offset * 2.0 / shadowMapResolution;

        result += step(shadowPos.z - texture2D(shadowtex1, shadowPos.xy+offset).r, 0.001);
    }
    
    return result / pcfSamples;
}