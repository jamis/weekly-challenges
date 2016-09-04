#include <stdlib.h>
#include <math.h>
#include "perlin.h"

static float* compute_vectors(int width, int height);
static float lerp(float a0, float a1, float w);
static float fade(float t);
static float dot_grid_gradient(float* vectors, int ix, int iy, int w, float x, float y);
static float perlin_at(float* vectors, float x, float y, int width);


static float lerp(float a0, float a1, float w)
{
  return (1.0 - w) * a0 + w * a1;
}

static float fade(float t)
{
  float t3 = t * t * t;
  float t4 = t * t3;
  float t5 = t * t4;

  return 6.0 * t5 - 15.0 * t4 + 10.0 * t3;
}

static float dot_grid_gradient(float* vectors, int ix, int iy, int w, float x, float y)
{
  float dx = x - (float)ix;
  float dy = y - (float)iy;

  int index = 2 * (iy * w + ix);

  return (dx * vectors[index] + dy * vectors[index+1]);
}

static float perlin_at(float* vectors, float x, float y, int width)
{
  int x0 = (x > 0.0) ? (int)x : ((int)x - 1);
  int x1 = x0 + 1;
  int y0 = (y > 0.0) ? (int)y : ((int)y - 1);
  int y1 = y0 + 1;

  float sx = fade(x - (float)x0);
  float sy = fade(y - (float)y0);

  float n0 = dot_grid_gradient(vectors, x0, y0, width, x, y);
  float n1 = dot_grid_gradient(vectors, x1, y0, width, x, y);
  float ix0 = lerp(n0, n1, sx);
  n0 = dot_grid_gradient(vectors, x0, y1, width, x, y);
  n1 = dot_grid_gradient(vectors, x1, y1, width, x, y);
  float ix1 = lerp(n0, n1, sx);

  return lerp(ix0, ix1, sy);
}

void perlin(image_t img, int gridw, int gridh)
{
  int width = image_width(img);
  int height = image_height(img);

  float *vectors = compute_vectors(gridw, gridh);

  float sx = (float)(gridw-1) / (float)width;
  float sy = (float)(gridh-1) / (float)height;

  for (int y = 0; y < height; y++)
    for (int x = 0; x < width; x++)
    {
      float value = perlin_at(vectors, x*sx, y*sy, gridw);
      uint8_t intensity = (int)(255.0 * (value + 1) / 2.0);
      color_t color = (intensity << 16) + (intensity << 8) + intensity;
      image_set_pixel(img, x, y, color);
    }

  free(vectors);
}


static float *compute_vectors(int width, int height)
{
  float *vectors = (float*)malloc(2 * width * height * sizeof(float));

  for(int y = 0; y < height; y++)
    for(int x = 0; x < width; x++)
    {
      int index = 2 * (y * width + x);

      if (x == width-1) {
        vectors[index+0] = vectors[y*width*2];
        vectors[index+1] = vectors[y*width*2+1];
      } else if (y == height-1) {
        vectors[index+0] = vectors[x*2];
        vectors[index+1] = vectors[x*2+1];
      } else {
        float angle = (rand() % 360) * M_PI / 180.0;
        vectors[index+0] = cos(angle); // x component
        vectors[index+1] = sin(angle); // y component
      }
    }

  return vectors;
}
