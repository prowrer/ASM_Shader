vec4 atrous(in vec2 coord, in vec3 c, in vec3 n, in vec3 p, in Material m) // for SSRT
{
    vec2 step_ = 1.0 / ScreenResolution;

    int samples = 2;
    int kernelSize = 3;
    kernelSize = int(exp2(float(kernelSize)));

    #ifdef russianRoulette
        float specChance = min(m.f0, 229.0/255.0);
        m.albedo = min(m.albedo, 1.0 - specChance);
        float diffChance = dot(m.albedo, vec3(0.333));
        float sum = specChance + diffChance;
        specChance /= sum;
        diffChance /= sum;
        bool roulette = interleaved(gl_FragCoord.xy) < specChance;
        roulette = m.is_metal ? true : roulette;

        kernelSize = roulette ? int(min(m.roughness * kernelSize, float(kernelSize))) : kernelSize;
    #else
        kernelSize = int(min(m.roughness * kernelSize, float(kernelSize)));
    #endif

    const float c_phi = 0.005;
    const float n_phi = 0.005;
    const float p_phi = 0.01;

    float sum_w = 0.0;
    vec4 result = vec4(0.0);
    for (int x = 0; x < samples; x++)
    {
        for (int y = 0; y < samples; y++)
        {
            vec2 xy = (vec2(x, y) + randV2(coord)) / samples;
            xy = (xy * 2.0 - 1.0) * kernelSize;
            vec2 newUV = coord + xy*step_;

            // Make sure the coordinates are not out of bound
            if (newUV.x > 1.0)
                newUV.x = 1.0 - fract(newUV.x);
            else if (newUV.x < 0.0)
                newUV.x = fract(-newUV.x);
            else if (newUV.y > 1.0)
                newUV.y = 1.0 - fract(newUV.y);
            else if (newUV.y < 0.0)
                newUV.y = fract(-newUV.y);

            vec3 c_s = getAlbedo(newUV).rgb;
            vec3 n_s = getNormals(newUV).rgb;
            vec3 p_s = screenToView(newUV, getDepth(newUV));

            vec3 t = c - c_s;
            float c_w = dot(t, t);
            c_w = exp(-c_w / c_phi);

            t = n - n_s;
            float n_w = dot(t, t);
            n_w = exp(-n_w / n_phi);

            t = p - p_s;
            float p_w = dot(t, t);
            p_w = exp(-p_w / p_phi);

            float weights = c_w * p_w * n_w;

            sum_w += weights;
            result += getSSRT(newUV) * weights;
        }
    }
    result /= sum_w;

    return result;
}