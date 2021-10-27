void getPredefinedMetal(in float spectex_y, inout vec3 metalProperties[2])
{
    // metalProperties[0] = N, metalProperties[1] = K
    int metalID = int(spectex_y*255.0 - 229.5); // 0 - 7
    switch(metalID)
    {
        case 0: // Iron
        {
            metalProperties = vec3[](
                vec3(2.9114, 2.9497, 2.5845),
                vec3(3.0893, 2.9318, 2.7670)
            );
            break;
        }
        case 1: // Gold
        {
            metalProperties = vec3[](
                vec3(0.18299, 0.42108, 1.3734),
                vec3(3.4242, 2.3459, 1.7704)
            );
            break;
        }
        case 2: // Aluminium
        {
            metalProperties = vec3[](
                vec3(1.3456, 0.96521, 0.61722),
                vec3(7.4746, 6.3995, 5.3031)
            );
            break;
        }
        case 3: // Chrome
        {
            metalProperties = vec3[](
                vec3(3.1071, 3.1812, 2.3230),
                vec3(3.3314, 3.3291, 3.1350)
            );
            break;
        }
        case 4: // Copper
        {
            metalProperties = vec3[](
                vec3(0.27105, 0.67693, 1.3164),
                vec3(3.6092, 2.6248, 2.2921)
            );
            break;
        }
        case 5: // Lead
        {
            metalProperties = vec3[](
                vec3(1.9100, 1.8300, 1.4400),
                vec3(3.5100, 3.4000, 3.1800)
            );
            break;
        }
        case 6: // Platinum
        {
            metalProperties = vec3[](
                vec3(2.3757, 2.0847, 1.8453),
                vec3(4.2655, 3.7153, 3.1365)
            );
            break;
        }
        case 7: // Silver
        {
            metalProperties = vec3[](
                vec3(0.15943, 0.14512, 0.13547),
                vec3(3.9291, 3.1900, 2.3808)
            );
            break;
        }
    }
}

/* Specular BRDF */
float D_GGX(float NH, float roughness)
{
    float a = NH * roughness;
    float k = roughness / (a*a - NH*NH + 1.0);
    return k * k * M_INV_PI * NH;
}
float G1_GGX(float Ndot, float roughness)
{
    float denominator = Ndot + sqrt(roughness + (1.0 - roughness)*Ndot*Ndot);
    return 2.0*Ndot / denominator;
}
float G_SmithGGX(float NV, float NL, float roughness)
{
    float a2 = roughness*roughness; // G1_GGX requires that we square the roughness value

    float GL = G1_GGX(NL, a2);
    float GV = G1_GGX(NV, a2);
    return GL*GV;
}
vec3 complexFresnel(in vec3 n, in vec3 k, in float c)
{
    vec3 k2 = k * k;
    vec3 rs_num = n*n + k2 - 2.0*n*c + c*c;
    vec3 rs_den = n*n + k2 + 2.0*n*c + c*c;
    vec3 rs = rs_num / rs_den;

    vec3 rp_num = (n*n + k2)*c*c - 2.0*n*c + 1.0;
    vec3 rp_den = (n*n + k2)*c*c + 2.0*n*c + 1.0;
    vec3 rp = rp_num / rp_den;
     
    return clamp(0.5 * (rs+rp), 0.0, 1.0);
}
vec3 FSchlick(in float cosTheta, in vec3 F0)
{
	return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}
vec3 fresnelFunction(in vec3 color, in float cosTheta, in vec3 n, in vec3 k, in float spectex_y)
{
    bool isnot_predefinedMetal = spectex_y*255.0 >= 255.0;
    bool is_metal = spectex_y*255.0 > 229.5;
    vec3 F0 = mix(vec3(min(spectex_y, 229.0/255.0)), color, (is_metal ? 1.0 : 0.0));

    return (is_metal ? (isnot_predefinedMetal ? FSchlick(cosTheta, F0) : complexFresnel(n, k, cosTheta)) : FSchlick(cosTheta, F0));
}
vec3 cookTorrance(in vec3 v, in vec3 n, in vec3 l, in vec3 color, in float roughness, in float spectex_y)
{
    v = -v;
	vec3 h = normalize(v + l);
    vec3 metalProperties[2]; getPredefinedMetal(spectex_y, metalProperties);

    float NV = max(dot(n, v), 1e-5);
    float NL = max(dot(n, l), 1e-5);
    float NH = max(dot(n, h), 1e-5);
    float LH = max(dot(l, h), 1e-5);

	float D = D_GGX(NH, roughness);
	vec3 F = fresnelFunction(color, LH, metalProperties[0], metalProperties[1], spectex_y);
	float G = G_SmithGGX(NV, NL, roughness);
	
    vec3 DFG = D * F * G;
    float denominator = 4.0 * NL * NV;

    return DFG / denominator;
}

/* Diffuse BRDF */
float orenNayar(in vec3 viewDir, in vec3 normal, in vec3 lightDir, in float roughness)
{
    roughness *= roughness;
    
    float NdotL = dot(normal.xyz, lightDir.xyz);
    float NdotV = dot(normal.xyz, viewDir.xyz);
    
    float t = max(NdotL,NdotV);
    float g = max(0.0, dot(viewDir - normal.xyz * NdotV, lightDir - normal.xyz * NdotL));
    float c = g/t - g*t;
    
    float a = 0.285 / (roughness + 0.57) + 0.5;
    float b = 0.45 * roughness / (roughness + 0.09);

    return max(0.0, NdotL) * (b * c + a);
}