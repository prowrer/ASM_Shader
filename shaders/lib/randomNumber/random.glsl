uniform sampler2D noisetex;
/*
const int noiseTextureResolution = 16;
*/

float _seed = frameCounter;

float rand(in vec2 co)
{
    float result = fract(sin(_seed / 100.0 * dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    _seed++;
    return result;
}
float interleaved(vec2 coord)
{
    float noise = fract(52.9829189 * fract(0.06711056 * coord.x + 0.00583715*coord.y));
    noise = mod(noise + goldRatio * _seed, 1.0);
    _seed++;
    return noise;
}

vec2 randV2(in vec2 co) { return vec2(rand(co), rand(co)); }

vec3 randV3(in vec2 co) { return vec3(rand(co), rand(co), rand(co)); }

vec3 randomInSphere(in vec2 coord)
{
    vec2 Xi = randV2(coord);

    float theta = acos(2.0 * Xi.x - 1.0);
    float phi = 2.0 * Xi.y * M_PI;
    
    float x = cos(phi) * sin(theta);
    float y = sin(phi) * sin(theta);
    float z = cos(theta);

    return vec3(x, y, z);
}