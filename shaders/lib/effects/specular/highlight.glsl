// This file contains code to compute specular highlight

vec3 specularHighlight(in vec3 v, in vec3 l, in vec3 n, in Material m, in float s, in vec3 color)
{
    vec3 kS = cookTorrance(v, n.xyz, l, m.albedo, m.roughness, m.f0);
    kS = mix(kS, sqrt(kS) * sqrt(m.albedo), m.metalness);
    // note: sqrt(kS) * sqrt(albedo) is done because they are somewhat similar, therefore we can imagine sqrt(x)^2 = x
    kS = kS * (1.0 - m.roughness) * s;

    color = mix(color, color * (ambientLight / 2.0), m.metalness);
    color += kS;

    return color;
}