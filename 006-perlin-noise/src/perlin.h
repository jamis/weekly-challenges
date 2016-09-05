#ifndef __PERLIN_H__
#define __PERLIN_H__

#include "image.h"

typedef void* perlin_t;

perlin_t perlin_init(int size);
void     perlin_destroy(perlin_t state);

void perlin(image_t image, perlin_t state, double dx, double dy, double dz, double sx, double sy, double sz);
double perlin_at(perlin_t state, double x, double y, double z);

#endif
