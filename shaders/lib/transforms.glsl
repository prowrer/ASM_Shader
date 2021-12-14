uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;

vec3 nvecw(in vec4 v) { return v.xyz / v.w; }

vec3 screenToView(in vec2 coord, in float depth)
{
    vec4 pos = vec4(coord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    pos = gbufferProjectionInverse * pos;
    pos /= pos.w;

    return pos.xyz;
}
vec3 screenToView(in vec3 screenVec)
{
    vec4 pos = vec4(screenVec * 2.0 - 1.0, 1.0);
    pos = gbufferProjectionInverse * pos;
    pos /= pos.w;

    return pos.xyz;
}
vec3 viewToClip(in vec3 viewVec) // we are just going to expect that people are going to do 0.5f(x) + 0.5
{
    return nvecw(gbufferProjection * vec4(viewVec, 1.0));
}

vec3 viewToWorld(in vec3 viewVec)
{
    return (gbufferModelViewInverse * vec4(viewVec, 1.0)).xyz;
}
vec3 worldToView(in vec3 worldVec)
{
    return (gbufferModelView * vec4(worldVec, 1.0)).xyz;
}

mat3 ArbitraryTBN(in vec3 normal)
{
    // Taken from https://github.com/BruceKnowsHow/Octray
    mat3 ret;
    ret[2] = normal;
    ret[0] = normalize(vec3(sqrt(2), sqrt(3), sqrt(5)));
    ret[1] = normalize(cross(ret[0], ret[2]));
    ret[0] = cross(ret[1], ret[2]);
    
    return ret;
}