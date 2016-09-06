#ifndef __PERLIN_H__
#define __PERLIN_H__

#include "image.h"

typedef void* perlin_t;

perlin_t perlin_init();
void     perlin_destroy(perlin_t state);

void perlin(image_t image, perlin_t state, double frequency, double dx, double dy, double dz);
double perlin_at(perlin_t state, double x, double y, double z);

#endif
