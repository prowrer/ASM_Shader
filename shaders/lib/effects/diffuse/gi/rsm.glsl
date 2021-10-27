uniform sampler2D shadowcolor;

vec3 reflectiveShadowMap(in vec3 viewPos, in vec3 normal)
{
    /*vec3 randomDir = randomInSphere(gl_FragCoord.xy);
    randomDir = dot(randomDir, normal) > 0.0 ? randomDir : -randomDir;
    randomDir = worldToShadow(viewToWorld(randomDir));*/
    
    vec3 shadowPos = worldToShadow(viewToWorld(viewPos));
    shadowPos = shadowToShadowView(shadowPos.xy, texture2D(shadowtex0, shadowPos.xy * 0.5 + 0.5).r);

    return shadowPos;
}