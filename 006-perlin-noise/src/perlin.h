#ifndef __PERLIN_H__
#define __PERLIN_H__

#include "image.h"

typedef void* perlin_t;
typedef color_t (*color_fn)(double value);

typedef struct {
  perlin_t state;

  int      octaves;
  double   persistence;
  double   dx;
  double   dy;
  double   dz;
  color_fn color;

  double   frequency;
  double   amplitude;
} perlin_config_t;

perlin_t perlin_init();
void     perlin_destroy(perlin_t state);

void     perlin_config_init(perlin_config_t *config, perlin_t state);

void perlin(image_t image, perlin_config_t *config);
double perlin_at(perlin_t state, double x, double y, double z);

color_t perlin_grayscale(double value);
color_t perlin_fire(double value);

#endif
