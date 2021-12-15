#version 120

varying vec2 texcoord;
varying vec2 lmCoord;
varying vec3 normal;
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

    mat3 TBN = mat3(tangent, cross(normal, tangent), normal); // we need this to align our normal map to surface normal
    vec3 normal = texture2D(normals, texcoord).rgb; // sample the normal map texture
    albedo.rgb *= normal.z; // multiply albedo by ambient occlusion (blue channel), this is how LabPbr v1.3 works
    normal.xy = normal.xy * 2.0 - 1.0; // convert to [-1, 1] range
    normal.z = sqrt(1.0 - dot(normal.xy, normal.xy)); // reconstruct the Z value of the normal
    normal = TBN * normal; // align the normal by TBN matrix

    /* DRAWBUFFERS: 0123 */
    gl_FragData[0] = albedo * light;
    gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0f);
    gl_FragData[2] = albedo;
    gl_FragData[3] = vec4(texture2D(specular, texcoord).rgb, 1.0);
}