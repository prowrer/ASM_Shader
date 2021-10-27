float fade(in float x)
{
    return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

float perlin(in vec2 coord)
{
    vec2 v0 = floor(coord);
    vec2 v1 = vec2(floor(coord.x), ceil(coord.y));
    vec2 v2 = vec2(ceil(coord.x), floor(coord.y));
    vec2 v3 = ceil(coord);

    /* Layout of the vNs per unit:
        v1 ---------- v3
         |            |
         |            |
         |            |
         |            |
        v0 ---------- v2
    */

    // Calculate gradient vectors for each corner
    vec2 grad0 = randomInSphere(v0).xy;
    vec2 grad1 = randomInSphere(v1).xy;
    vec2 grad2 = randomInSphere(v2).xy;
    vec2 grad3 = randomInSphere(v3).xy;

    // Calculate directions from vNs to P
    // also, do not ever normalize these vectors, I spent hours just to find out I shouldn't normalize them
    vec2 pToV0 = coord - v0;
    vec2 pToV1 = coord - v1;
    vec2 pToV2 = coord - v2;
    vec2 pToV3 = coord - v3;

    // Calculate dot products between (vN -> P) and (gradN)
    float dprod0 = dot(pToV0, grad0);
    float dprod1 = dot(pToV1, grad1);
    float dprod2 = dot(pToV2, grad2);
    float dprod3 = dot(pToV3, grad3);

    // calculate weights for the mix process
    vec2 weights = fract(coord);
    weights = vec2(fade(weights.x), fade(weights.y));

    // Linearly mix between the dot products horizontally first
    float x1 = mix(dprod0, dprod2, weights.x);
    float x2 = mix(dprod1, dprod3, weights.x);

    // Then return a vertical mix between x1 and x2
    return mix(x1, x2, weights.y) * 0.5 + 0.5;
}

float octavePerlin(in vec2 coord, in int octaves)
{
    // pre-compute values
    float persistence = 1.0 - 1.0 / octaves;

    // add multiple perlin noise with 2x higher frequency and lower amplitude by N times
    float total = 0.0;
    float frequency = 1.0;
    float amplitude = 1.0;
    float maxValue = 0.0;  // Used for normalizing result to 0.0 - 1.0
    for(int i = 0; i < octaves; i++)
    {
        total += perlin(coord * frequency) * amplitude;
        
        maxValue += amplitude;
        
        amplitude *= persistence;
        frequency *= 2.0;
    }
    
    // then average the result
    return total/maxValue;
}