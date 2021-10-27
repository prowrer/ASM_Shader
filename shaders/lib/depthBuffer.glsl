uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

float getDepth(in vec2 coord)
{
    return texture2D(depthtex0, coord).r;
}
float getDepth(in vec2 coord, in int index)
{
    if (index == 0)
        return texture2D(depthtex0, coord).r;
    else
    if (index == 1)
        return texture2D(depthtex1, coord).r;
    else
    if (index == 2)
        return texture2D(depthtex2, coord).r;
}