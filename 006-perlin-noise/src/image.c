#include <stdlib.h>
#include <stdio.h>
#include "image.h"

typedef struct {
  int width;
  int height;
  color_t *pixels;
} image_struct;

image_t image_new(int width, int height, color_t background)
{
  int i, count = width * height;

  image_struct *image = (image_struct*)malloc(sizeof(image_struct));

  image->width = width;
  image->height = height;

  image->pixels = (color_t*)malloc(sizeof(color_t) * count);
  for(i = 0; i < count; i++) image->pixels[i] = background;

  return (image_t)image;
}

void image_destroy(image_t img)
{
  image_struct *image = (image_struct*)img;

  if (image->pixels) {
    free(image->pixels);
    image->pixels = NULL;
  }

  free(image);
}

int image_width(image_t img)
{
  image_struct *image = (image_struct*)img;
  return image->width;
}

int image_height(image_t img)
{
  image_struct *image = (image_struct*)img;
  return image->height;
}

void image_set_pixel(image_t img, int x, int y, color_t color)
{
  image_struct *image = (image_struct*)img;

  if (x >= 0 && y >= 0 && x < image->width && y < image->height) {
    int index = y * image->width + x;
    image->pixels[index] = color;
  }
}

color_t image_get_pixel(image_t img, int x, int y) {
  image_struct *image = (image_struct*)img;

  if (x >= 0 && y >= 0 && x < image->width && y < image->height) {
    int index = y * image->width + x;
    return image->pixels[index];
  }

  return 0;
}

void image_normalize(image_t img) {
  image_struct *image = (image_struct*)img;

  int max_red = 0, max_green = 0, max_blue = 0;
  int min_red = 255, min_green = 255, min_blue = 255;

  int pixels = image->width * image->height;
  for(int index = 0; index < pixels; index++) {
    int red   = (image->pixels[index] & 0x00ff0000) >> 16;
    int green = (image->pixels[index] & 0x0000ff00) >>  8;
    int blue  = (image->pixels[index] & 0x000000ff) >>  0;

    if (red > max_red) max_red = red;
    if (blue > max_blue) max_blue = blue;
    if (green > max_green) max_green = green;

    if (red < min_red) min_red = red;
    if (blue < min_blue) min_blue = blue;
    if (green < min_green) min_green = green;
  }

  for(int index = 0; index < pixels; index++) {
    int red   = (image->pixels[index] & 0x00ff0000) >> 16;
    int green = (image->pixels[index] & 0x0000ff00) >>  8;
    int blue  = (image->pixels[index] & 0x000000ff) >>  0;

    red = 255 * (red - min_red) / (double)(max_red - min_red);
    green = 255 * (green - min_green) / (double)(max_green - min_green);
    blue = 255 * (blue - min_blue) / (double)(max_blue - min_blue);

    image->pixels[index] = (red << 16) + (green << 8) + blue;
  }
}

void image_recolor(image_t img, recolor_fn fn) {
  image_struct *image = (image_struct*)img;

  int pixels = image->width * image->height;
  for(int index = 0; index < pixels; index++) {
    uint8_t red   = (image->pixels[index] & 0x00ff0000) >> 16;
    uint8_t green = (image->pixels[index] & 0x0000ff00) >>  8;
    uint8_t blue  = (image->pixels[index] & 0x000000ff) >>  0;

    image->pixels[index] = fn(red, green, blue);
  }
}

void image_save_ppm(image_t img, char *filename) {
  image_struct *image = (image_struct*)img;
  FILE *f = fopen(filename, "wt");

  if (f) {
    int pixel = 0;

    fprintf(f, "P3\n%d %d\n255\n", image->width, image->height);
    for(int y = 0; y < image->height; y++) {
      for(int x = 0; x < image->width; x++) {
        color_t color = image->pixels[pixel++];

        uint8_t red   = (color & 0x00ff0000) >> 16;
        uint8_t green = (color & 0x0000ff00) >>  8;
        uint8_t blue  = (color & 0x000000ff) >>  0;

        fprintf(f, "%s%3d %3d %3d",
                (x > 0) ? " " : "",
                red, green, blue);
      }
      fprintf(f, "\n");
    }

    fclose(f);
  }
}
