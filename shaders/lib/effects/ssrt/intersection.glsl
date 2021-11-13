void refineIntersection(in float delta, in vec3 r, inout vec2 coord, inout vec3 p, inout vec3 p_s)
{
    const float BINARY_REFINEMENT_STEPS = 4;

    float BINARY_STEP = length(p - p_s); // decrease by half every iteration
    for (int j = 0; j < BINARY_REFINEMENT_STEPS; j++)
    {
        if (delta > 0.0)
        {
            p -= r * BINARY_STEP;
            coord = viewToClip(p).xy * 0.5 + 0.5;
            
            p_s = screenToView(coord, getDepth(coord));

            delta = p_s.z - p.z;
        }
        else if (delta < 0.0)
        {
            p += r * BINARY_STEP;
            coord = viewToClip(p).xy * 0.5 + 0.5;
            
            p_s = screenToView(coord, getDepth(coord));

            delta = p_s.z - p.z;
        }

        BINARY_STEP *= 0.5;
    }
}

bool intersect(inout vec3 p, inout vec2 coord, in vec3 r, in int stepCount, in float stepSize)
{
    /*
    P must be in view space and is a position
    coord must be in screen space
    r must be in view space and represents reflection direction, which is normalized
    stepCount represent how many steps to march in screen space
    stepSize is self explanatory, size of every steps
    */

    // The actual code
    vec3 orig = p;
    vec3 rayDir = r * stepSize;
    p += rayDir;
    for (int i = 0; i < stepCount; i++)
    {
        coord = viewToClip(p).xy * 0.5 + 0.5;
        if (coord.x > 1.0 || coord.x < 0.0 || coord.y > 1.0 || coord.y < 0.0) break;

        float depth_s = getDepth(coord);
        vec3 p_s = screenToView(coord, depth_s);

        float delta = p_s.z - p.z;

        vec3 orig2p = normalize(p_s - orig);

        if (delta >= 0.0)
        {
            // Binary refinement, sum good stuf
            refineIntersection(delta, r, coord, p, p_s);
            return true;
        }
        
        rayDir *= interleaved(gl_FragCoord.xy)*0.5 + 1.0;
        p += rayDir;
    }

    return false;
}