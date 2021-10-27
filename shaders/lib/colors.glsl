float luminance(vec3 v)
{
    return dot(v, vec3(0.2126, 0.7152, 0.0722));
}
vec3 adjust_luminance(vec3 c_in, float l_out)
{
    float l_in = luminance(c_in);
    return c_in * (l_out / l_in);
}

vec3 reinhard(vec3 v)
{
    float l = luminance(v);
    vec3 tv = v / (1.0 + v);

    return mix(v / (1.0 + l), tv, tv);
}
vec3 aces_approx(in vec3 color)
{
    color *= 0.6f;
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((color*(a*color+b))/(color*(c*color+d)+e), 0.0f, 1.0f);
}