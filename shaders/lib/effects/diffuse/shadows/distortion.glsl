// Written by Builderboy

float cubeLength(in vec2 v)
{
    return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}

float getDistortFactor(in vec2 v, in float factor)
{
    return cubeLength(v) + factor;
}

vec3 distortPosition(in vec3 v)
{
    /*float CenterDistance = length(v);
    float DistortionFactor = mix(1.0f, CenterDistance, 0.5f);
    return v / DistortionFactor;*/
    return vec3(v.xy / getDistortFactor(v.xy, 0.1), v.z * 0.5);
}