bool rayIntersect_sphere
(
    // Ray
    vec3 O, // Origin
    vec3 D, // Direction
    // Sphere
    vec3 C, // Centre
    float R,    // Radius
    out vec2 VO // Intersection times (First, Second)
)
{
    vec3 L = C - O;
    float DT = dot (L, D);
    float R2 = R * R;
    float CT2 = dot(L,L) - DT*DT;
    
    float AT = sqrt(R2 - CT2);
    float BT = AT;
    VO.x = DT - AT;
    VO.y = DT + BT;

    // Intersection point outside the circle
    if (CT2 > R2 || VO.y < 0.0)
        return false;
    return true;
}