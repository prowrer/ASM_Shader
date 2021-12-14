#version 120

varying vec2 texcoord;
varying vec2 lmCoord;
varying vec4 normal;
varying vec3 tangent;
varying vec4 color;

varying float isnt_water;

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2D specular;

void main()
{
    vec4 albedo = texture2D(texture, texcoord) * color;
    albedo.rgb = pow(albedo.rgb, vec3(2.2));
    vec4 light = texture2D(lightmap, lmCoord);
    vec4 specTex = texture2D(specular, texcoord);

    /* DRAWBUFFERS: 0129 */
    gl_FragData[0] = albedo * light * vec4(1.0, 1.0, 1.0, isnt_water);
    gl_FragData[1] = vec4(normal.rgb * 0.5 + 0.5, normal.a);
    gl_FragData[2] = mix(vec4(1.0), albedo, isnt_water);
    gl_FragData[3] = vec4(mix(1.0, specTex.r, isnt_water), mix(0.02, specTex.g, isnt_water), specTex.b, specTex.a);
}