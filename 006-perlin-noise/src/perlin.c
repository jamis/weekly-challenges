#include <stdlib.h>
#include <math.h>
#include "perlin.h"

typedef struct {
  int size; /* cubes per unit -- and points per cube */
  int points; /* number of points per unit (size*size) */
  double *vectors;
} perlin_state_t;

static double lerp(double a, double b, double t);
static double fade(double t);
static double gradient(perlin_state_t *state, int ix, int iy, int iz, double x, double y, double z);


perlin_t perlin_init(int size)
{
  int sizen = size + 1;
  int count = sizen * sizen * sizen;

  perlin_state_t *data = (perlin_state_t*)malloc(sizeof(perlin_state_t));

  data->size = size;
  data->points = size*size;
  data->vectors = (double*)malloc(sizeof(double) * count * 3);

  for(int i = 0; i <= size; i++) {
    int zbase = i * sizen * sizen;

    for(int j = 0; j <= size; j++) {
      int ybase = zbase + j * sizen;

      for(int k = 0; k <= size; k++) {
        int index = 3 * (ybase + k);

        if (k == size) {
          int origin = 3 * ybase;
          data->vectors[index+0] = data->vectors[origin+0];
          data->vectors[index+1] = data->vectors[origin+1];
          data->vectors[index+2] = data->vectors[origin+2];
        } else if (j == size) {
          int origin = 3 * (zbase + k);
          data->vectors[index+0] = data->vectors[origin+0];
          data->vectors[index+1] = data->vectors[origin+1];
          data->vectors[index+2] = data->vectors[origin+2];
        } else if (i == size) {
          int origin = 3 * (j * sizen + k);
          data->vectors[index+0] = data->vectors[origin+0];
          data->vectors[index+1] = data->vectors[origin+1];
          data->vectors[index+2] = data->vectors[origin+2];
        } else {
          double theta = (rand() % 36) * 18.0 / M_PI;
          double phi   = (rand() % 18) * 18.0 / M_PI;

          double sin_t = sin(theta);
          double cos_t = cos(theta);
          double sin_p = sin(phi);
          double cos_p = cos(phi);

          data->vectors[index+0] = sin_t * cos_p;
          data->vectors[index+1] = sin_t * sin_p;
          data->vectors[index+2] = cos_t;
        }
      }
    }
  }

  return (perlin_t)data;
}

void perlin_destroy(perlin_t state)
{
  perlin_state_t *data = (perlin_state_t*)state;

  free(data->vectors);
  data->vectors = NULL;

  free(data);
}

double perlin_at(perlin_t state, double x, double y, double z)
{
  perlin_state_t *data = (perlin_state_t*)state;

  /* normalize x,y,z to fit within the unit cube */
  x = fmod(x, data->size);
  y = fmod(y, data->size);
  z = fmod(z, data->size);

  /* identify the cube that contains the point */
  int x0 = (int)x;
  int y0 = (int)y;
  int z0 = (int)z;

  /* compute distance from point to origin of cube */
  double dx = x - x0;
  double dy = y - y0;
  double dz = z - z0;

  /* compute the fade curve of the point within the cube */
  double u = fade(dx);
  double v = fade(dy);
  double w = fade(dz);

  /* compute gradient from each corner of the cube */
  double p000 = gradient(data, x0,   y0,   z0,   x, y, z);
  double p100 = gradient(data, x0+1, y0,   z0,   x, y, z);
  double p010 = gradient(data, x0,   y0+1, z0,   x, y, z);
  double p001 = gradient(data, x0,   y0,   z0+1, x, y, z);
  double p110 = gradient(data, x0+1, y0+1, z0,   x, y, z);
  double p101 = gradient(data, x0+1, y0,   z0+1, x, y, z);
  double p011 = gradient(data, x0,   y0+1, z0+1, x, y, z);
  double p111 = gradient(data, x0+1, y0+1, z0+1, x, y, z);

  double u1 = lerp(p000, p100, u);
  double u2 = lerp(p010, p110, u);
  double u3 = lerp(p001, p101, u);
  double u4 = lerp(p011, p111, u);

  double v1 = lerp(u1, u2, v);
  double v2 = lerp(u3, u4, v);

  return lerp(v1, v2, w);
}

void perlin(image_t image, perlin_t state, double dx, double dy, double dz, double sx, double sy, double sz)
{
  perlin_state_t *data = (perlin_state_t*)state;

  int width = image_width(image);
  int height = image_height(image);

  sx *= (float)data->size / (float)width;
  sy *= (float)data->size / (float)height;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++)
    {
      double value = perlin_at(state, (x+dx)*sx, (y+dy)*sy, dz*sz);
      uint8_t intensity = (int)(255.0 * (value + 1) / 2.0);
      color_t color = (intensity << 16) + (intensity << 8) + intensity;
      image_set_pixel(image, x, y, color);
    }
  }
}

static double lerp(double a, double b, double t)
{
  return (1.0 - t) * a + t * b;
}

static double fade(double t)
{
  double t3 = t * t * t;
  double t4 = t * t3;
  double t5 = t * t4;

  return 6.0 * t5 - 15.0 * t4 + 10.0 * t3;
}

static double gradient(perlin_state_t *state, int ix, int iy, int iz, double x, double y, double z)
{
  int index = 3 * (
                iz * (state->size+1) * (state->size+1) +
                iy * (state->size+1) +
                ix
              );

  double dx = x - ix;
  double dy = y - iy;
  double dz = z - iz;

  double a = state->vectors[index+0];
  double b = state->vectors[index+1];
  double c = state->vectors[index+2];

  return dx * a + dy * b * dz * c;
}
