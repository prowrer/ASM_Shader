#version 120

attribute vec4 at_tangent;
attribute vec3 mc_Entity;

varying vec2 texcoord;
varying vec2 lmCoord;
varying vec4 normal;
varying vec3 tangent;
varying vec4 color;

varying float isnt_water;

// We wanna jitter the world for TAA
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
vec2 screenResolution = vec2(viewWidth, viewHeight);
float _Seed = frameCounter;


float rand(){_Seed++; return fract(sin(_Seed) * 43758.5453123);}

vec2 randV2() {return vec2(rand(), rand());}

void main()
{
    // Water should be completely transparent for reflections/absorption later
    isnt_water = 1.0 - float(mc_Entity.x == 8.0 || mc_Entity.x == 9.0);


    gl_Position = ftransform();
    gl_Position.xy = gl_Position.xy * 0.5 + 0.5; // UV space
    gl_Position.xy += (randV2()*2.0-1.0) * 0.5 / screenResolution * gl_Position.w; // multiply by 0.5 because of how OpenGL works
    gl_Position.xy = gl_Position.xy * 2.0 - 1.0; // back to clip space
    
    texcoord = gl_MultiTexCoord0.st;

    // Use the texture matrix instead of dividing by 15 to maintain compatiblity for each version of Minecraft
    lmCoord = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    // Transform them into the [0, 1] range
    lmCoord = (lmCoord * 33.05f / 32.0f) - (1.05f / 32.0f);

    normal = vec4(gl_NormalMatrix * gl_Normal, 1.0);

    tangent = gl_NormalMatrix * (at_tangent.xyz / at_tangent.w);

    color = gl_Color;
}