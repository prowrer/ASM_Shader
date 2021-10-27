#include "/lib/effects/diffuse/shadows/distortion.glsl"

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform mat4 shadowModelView;

uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;

vec3 worldToShadow(in vec3 worldVec)
{
    vec4 pos = shadowProjection * shadowModelView * vec4(worldVec, 1.0);
    pos /= pos.w;
    pos.xyz = distortPosition(pos.xyz);

    return pos.xyz;
}
vec3 worldToShadow(in vec2 coord)
{
    vec3 pos = screenToView(coord, texture2D(depthtex0, coord).r);
    pos = viewToWorld(pos);
    pos = nvecw(shadowProjection * shadowModelView * vec4(pos, 1.0));
    pos.xyz = distortPosition(pos.xyz);

    return pos.xyz;
}
vec3 shadowToShadowView(in vec2 shadowClip, in float shadowDepth)
{
    vec4 pos = vec4(shadowClip, shadowDepth * 2.0 - 1.0, 1.0);
    pos = shadowProjectionInverse * pos;
    pos /= pos.w;

    return pos.xyz;
}