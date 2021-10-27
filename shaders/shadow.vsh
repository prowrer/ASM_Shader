#version 120

varying vec2 texcoord;

#include "/lib/effects/diffuse/shadows/distortion.glsl"

void main()
{
    gl_Position = ftransform();
    gl_Position.xyz = distortPosition(gl_Position.xyz);
    
    texcoord = gl_MultiTexCoord0.st;
}