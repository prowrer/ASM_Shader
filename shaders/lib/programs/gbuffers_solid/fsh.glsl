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

    mat3 TBN = mat3(tangent, cross(normal.rgb, tangent), normal.rgb); // we need this to align our normal map to surface normal
    #ifdef noPBR_RP
        vec4 normal = normal;
    #else
        vec4 normal = texture2D(normals, texcoord); // sample the normal map texture
        albedo.rgb *= normal.z; // multiply albedo by ambient occlusion (blue channel), this is how LabPbr v1.3 works
        normal.xy = normal.xy * 2.0 - 1.0; // convert to [-1, 1] range
        normal.z = sqrt(1.0 - dot(normal.xy, normal.xy)); // reconstruct the Z value of the normal
        normal.rgb = TBN * normal.rgb; // align the normal by TBN matrix
    #endif

    /* DRAWBUFFERS: 0129 */
    gl_FragData[0] = albedo * light;
    gl_FragData[1] = vec4(normal.rgb * 0.5 + 0.5, pow(normal.a, 2.2));
    gl_FragData[2] = albedo;
    #ifdef noPBR_RP
        float avgAlbedo = dot(albedo.rgb, vec3(0.333));
        gl_FragData[3] = vec4(1.0 - sqrt(1.0 - avgAlbedo), min(avgAlbedo, 229.0/255.0), 0.0, 1.0);
    #else
        gl_FragData[3] = texture2D(specular, texcoord);
    #endif
}