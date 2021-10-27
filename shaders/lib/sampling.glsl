// Contains sampling functions for importance sampling and uniform monte carlo

// http://three-eyed-games.com/2018/05/12/gpu-path-tracing-in-unity-part-2/ for tangent direction


vec3 ImportanceSampleGGX(in vec3 n, in vec2 Xi, in float roughness)
{
    // https://agraphicsguy.wordpress.com/2015/11/01/sampling-microfacet-brdf/ for the Importance Sampling math for cosTheta

    float a = roughness;
    float cosTheta = sqrt((1.0 - Xi.x) / (Xi.x * (a*a - 1.0) + 1.0));
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
    float phi = 2.0 * M_PI * Xi.y;
    vec3 tangentSpaceDir = vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);

    // Transform direction to world space
    return ArbitraryTBN(n) * tangentSpaceDir;
}

vec3 ImportanceSampleCosine(in vec3 n, in vec2 Xi)
{
    float cosTheta = sqrt(Xi.x);
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
    float phi = 2.0 * M_PI * Xi.y;
    vec3 tangentSpaceDir = vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);

    // Transform direction to world space
    return ArbitraryTBN(n) * tangentSpaceDir;
}