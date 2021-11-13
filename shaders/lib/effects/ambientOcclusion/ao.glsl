float gtao(in vec2 coord, in vec3 normal_p, vec3 pos_p, vec3 viewDir)
{
    const int directions = 4;
    const int steps = 2;
    const float radius = 0.1; // in screen space

    float result = 0.0;
    for (int i = 0; i < directions; i++)
    {
        // Offset
        float ang = 2.4 * i + rand(coord) * M_PI2;
        vec2 offset = vec2(cos(ang), sin(ang));
        vec2 offsetDivRes = offset / ScreenResolution;

        // Calculate the horizon angle
        float h1 = M_PI2;
        float h2 = M_PI2;
        for (int j = 0; j < steps; j++)
        {
            float ranged = sqrt((j+interleaved(gl_FragCoord.xy))/steps);

            vec2 sampleUV = coord + offset*radius * ranged;
            vec3 pos_s = screenToView(sampleUV, getDepth(sampleUV, 1));
            vec3 horizonVec1 = normalize(pos_s - pos_p);

            sampleUV = coord - offset*radius * ranged;
            pos_s = screenToView(sampleUV, getDepth(sampleUV, 1));
            vec3 horizonVec2 = normalize(pos_s - pos_p);
            
            h1 = min(h1, fastAcos(dot(horizonVec1, -viewDir)));
            h2 = min(h2, fastAcos(dot(horizonVec2, -viewDir)));
        }
        float NVtheta = fastAcos(dot(normal_p, -viewDir));
        h1 = NVtheta + max(-h1 - NVtheta, -M_PI/2.0);
        h2 = NVtheta + min(h2 - NVtheta, M_PI/2.0);

        // We finally calculate ao
        result += 0.25*(-cos(2.0*h1 - NVtheta) + cos(NVtheta) + 2.0*h1*sin(NVtheta)) +
                    0.25*(-cos(2.0*h2 - NVtheta) + cos(NVtheta) + 2.0*h2*sin(NVtheta));
    }
    result /= directions;

    return clamp(result, 0.0, 1.0);
}