// Post process
#define doTemporal

// Materials
#define noPBR_RP // Enable this if you're not using any LabPBR resource pack. Inaccurate. No emissives, normal maps & metals.

// SSRT settings
#define russianRoulette // enabling will result in more accurate SSRT
#define doSSRT // Screen Space Ray Tracing
#define blurSSRT // Blur the accumulated ssrt result
#define MULTI_BOUNCE // change from 1 to 4 bounces for SSRT

// Shadows
#define PCSS // Percentage closer soft shadows