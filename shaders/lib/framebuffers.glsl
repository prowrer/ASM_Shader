uniform sampler2D colortex0; // main
uniform sampler2D colortex1; // normals
uniform sampler2D colortex2; // albedo
uniform sampler2D colortex3; // Shading information buffer (vanillaAO*textureAO, ?, ?, ?)
uniform sampler2D colortex4; // Previous SSRT buffer, clearing disabled
uniform sampler2D colortex5; // Previous buffer values (depth, ?, ?, ?)
uniform sampler2D colortex8; // Previous main buffer, clearing disabled
uniform sampler2D colortex9; // specular

vec4 getColor(in vec2 coord)
{
    return texture2D(colortex0, coord);
}
vec4 getNormals(in vec2 coord)
{
    vec4 tmp = texture2D(colortex1, coord);
    return vec4(normalize(tmp.xyz * 2.0 - 1.0), tmp.w);
}
vec3 getAlbedo(in vec2 coord)
{
    return texture2D(colortex2, coord).rgb;
}
vec4 getShadingInfo(in vec2 coord)
{
    return texture2D(colortex3, coord);
}
vec4 getPreviousSSRT(in vec2 coord)
{
    return texture2D(colortex4, coord);
}
vec4 getPreviousBufferValues(in vec2 coord)
{
    return texture2D(colortex5, coord);
}
vec4 getPreviousColor(in vec2 coord)
{
    return texture2D(colortex8, coord);
}
vec4 getSpecular(in vec2 coord)
{
    return texture2D(colortex9, coord);
}