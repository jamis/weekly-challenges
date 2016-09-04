#ifndef __IMAGE_H__
#define __IMAGE_H__

#include <inttypes.h>

typedef void*    image_t;
typedef uint32_t color_t;

image_t image_new(int width, int height, color_t background);
void    image_destroy(image_t img);

int     image_width(image_t img);
int     image_height(image_t img);

void    image_set_pixel(image_t img, int x, int y, color_t color);
color_t image_get_pixel(image_t img, int x, int y);

void    image_save_ppm(image_t img, char *filename);

#endif
