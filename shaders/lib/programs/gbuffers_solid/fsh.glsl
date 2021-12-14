#version 120

#include "/lib/settings.glsl"

varying vec2 texcoord;
varying vec2 lmCoord;
varying vec4 normal;
varying vec3 tangent;
varying vec4 color;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D specular;
uniform sampler2D normals;

void main()
{
    vec4 albedo = texture2D(texture, texcoord) * color;
    albedo.rgb = pow(albedo.rgb, vec3(2.2));
    vec4 light = texture2D(lightmap, lmCoord);
    vec4 shadingInfo = vec4(0.0);

    mat3 TBN = mat3(tangent, cross(normal.rgb, tangent), normal.rgb); // we need this to align our normal map to surface normal
    #ifdef noPBR_RP
        vec4 normal = normal;
        shadingInfo.r = color.a;
    #else
        vec4 normal = texture2D(normals, texcoord); // sample the normal map texture
        shadingInfo.r = color.a * normal.z;
        normal.xy = normal.xy * 2.0 - 1.0; // convert to [-1, 1] range
        normal.z = sqrt(1.0 - dot(normal.xy, normal.xy)); // reconstruct the Z value of the normal
        normal.rgb = TBN * normal.rgb; // align the normal by TBN matrix
    #endif

    /* DRAWBUFFERS: 01239 */
    gl_FragData[0] = albedo * light;
    gl_FragData[1] = vec4(normal.rgb * 0.5 + 0.5, pow(normal.a, 2.2));
    gl_FragData[2] = albedo;
    gl_FragData[3] = shadingInfo;
    #ifdef noPBR_RP
        float avgAlbedo = dot(albedo.rgb, vec3(0.333));
        gl_FragData[4] = vec4(1.0 - sqrt(1.0 - avgAlbedo), min(avgAlbedo, 229.0/255.0), 0.0, 1.0);
    #else
        gl_FragData[4] = texture2D(specular, texcoord);
    #endif
}