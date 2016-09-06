#include <stdlib.h>
#include <math.h>
#include "perlin.h"

typedef struct {
  uint16_t p[512];
} perlin_state_t;

static double lerp(double a, double b, double t);
static double fade(double t);
static double gradient(uint16_t hash, double x, double y, double z);


perlin_t perlin_init()
{
  perlin_state_t *data = (perlin_state_t*)malloc(sizeof(perlin_state_t));

  for(int i = 0; i < 256; i++) {
    data->p[i] = i;
  }

  for(int i = 255; i >= 1; i--) {
    int j = rand() % i;
    int temp = data->p[i];
    data->p[i] = data->p[j];
    data->p[j] = temp;
  }

  for(int i = 0; i < 256; i++) {
    data->p[i+256] = data->p[i];
  }

  return (perlin_t)data;
}

void perlin_destroy(perlin_t state)
{
  perlin_state_t *data = (perlin_state_t*)state;
  free(data);
}

double perlin_at(perlin_t state, double x, double y, double z)
{
  perlin_state_t *data = (perlin_state_t*)state;

  int X = (int)x & 255;
  int Y = (int)y & 255;
  int Z = (int)z & 255;

  x -= (int)x;
  y -= (int)y;
  z -= (int)z;

  double u = fade(x);
  double v = fade(y);
  double w = fade(z);

  int A  = data->p[X  ]+Y;
  int AA = data->p[A  ]+Z;
  int AB = data->p[A+1]+Z;
  int B  = data->p[X+1]+Y;
  int BA = data->p[B  ]+Z;
  int BB = data->p[B+1]+Z;

  double p000 = gradient(data->p[AA  ], x,   y,   z  );
  double p100 = gradient(data->p[BA  ], x-1, y,   z  );
  double p010 = gradient(data->p[AB  ], x,   y-1, z  );
  double p110 = gradient(data->p[BB  ], x-1, y-1, z  );
  double p001 = gradient(data->p[AA+1], x,   y,   z-1);
  double p101 = gradient(data->p[BA+1], x-1, y,   z-1);
  double p011 = gradient(data->p[AB+1], x,   y-1, z-1);
  double p111 = gradient(data->p[BB+1], x-1, y-1, z-1);

  double u1 = lerp(p000, p100, u);
  double u2 = lerp(p010, p110, u);
  double u3 = lerp(p001, p101, u);
  double u4 = lerp(p011, p111, u);

  double v1 = lerp(u1, u2, v);
  double v2 = lerp(u3, u4, v);

  return lerp(v1, v2, w);
}

void perlin(image_t image, perlin_t state, double frequency, double dx, double dy, double dz)
{
  perlin_state_t *data = (perlin_state_t*)state;

  int width = image_width(image);
  int height = image_height(image);

  double scale = frequency / (float)width;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++)
    {
      double value = perlin_at(state, (x+dx)*scale, (y+dy)*scale, dz*scale);
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

static double gradient(uint16_t hash, double x, double y, double z)
{
  int h = hash % 15;
  double u = (h < 8) ? x : y;
  double v = (h < 4) ? y : ((h == 12 || h == 14) ? x : z);

  return (((h&1) == 0) ? u : -u) +
         (((h&2) == 0) ? v : -v);
}
