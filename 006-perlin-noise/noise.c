#include <time.h>
#include <stdlib.h>
#include <stdio.h>

#include "image.h"
#include "perlin.h"

typedef struct {
  int        frames;
  recolor_fn color;
  double     speed_x;
  double     speed_y;
  double     speed_z;
  char*      frame_name;
  time_t     seed;
  int        width;
  int        height;
  double     frequency;
  double     persistence;
  int        octaves;
} options_t;

color_t recolor_fire(uint8_t red, uint8_t green, uint8_t blue)
{
  if (red < 128) {
    return 0x000000;
  } else {
    double value = red / 255.0;
    red = 255;
    green = 255 * value;
    return (red << 16) + (green << 8);
  }
}

color_t recolor_terrain(uint8_t red, uint8_t green, uint8_t blue)
{
  if (red < 64) {
    return 0x0b1fa0;
  } else if (red < 128) {
    return 0x0e27cd;
  } else if (red < 140) {
    return 0xffd574;
  } else if (red < 180) {
    return 0x2f9742;
  } else if (red < 220) {
    return 0x937751;
  } else {
    return 0xffffff;
  }
}

void parse_options(int argc, char *argv[], options_t *options)
{
  int opt = 1;

  options->frames      = 1;
  options->color       = NULL;
  options->speed_x     = 4.0;
  options->speed_y     = 4.0;
  options->speed_z     = 4.0;
  options->frame_name  = "anim-%03d.ppm";
  options->seed        = time(NULL);
  options->width       = 256;
  options->height      = 256;
  options->frequency   = 4.0;
  options->octaves     = 8;
  options->persistence = 0.5;

  while(opt < argc) {
    switch(argv[opt++][1]) {
      case 'f':
        options->frames = atoi(argv[opt++]);
        break;

      case 'r':
        options->seed = atol(argv[opt++]);
        break;

      case 'c':
        switch(argv[opt++][0]) {
          case 'g': options->color = NULL; break;
          case 'f': options->color = recolor_fire; break;
          case 't': options->color = recolor_terrain; break;
          default: printf("unknown color option: %s\n", argv[opt-1]);
        }
        break;

      case 's':
        options->speed_x =
          options->speed_y =
          options->speed_z = atof(argv[opt++]);
        break;

      case 'x':
        options->speed_x = atof(argv[opt++]);
        break;

      case 'y':
        options->speed_y = atof(argv[opt++]);
        break;

      case 'z':
        options->speed_z = atof(argv[opt++]);
        break;

      case 'n':
        options->frame_name = argv[opt++];
        break;

      case 'W':
        options->width = atoi(argv[opt++]);
        break;

      case 'H':
        options->height = atoi(argv[opt++]);
        break;

      case 'F':
        options->frequency = atof(argv[opt++]);
        break;

      case 'o':
        options->octaves = atoi(argv[opt++]);
        break;

      case 'p':
        options->persistence = atof(argv[opt++]);
        break;

      default:
        printf("usage: %s [-f num] [-c [gf]] [-r seed]\n", argv[0]);
        printf("       [-s num] [-x num] [-y num] [-z num]\n");
        printf("       [-W num] [-H num]\n");
        printf("       [-F num] [-o num] [-p num]\n");
        printf("       [-n name.ppm]\n");
        printf("\n");
        printf("  -f num   :: number of frames to generate\n");
        printf("  -c [gft] :: color scheme to use (g=grayscale, f=fire, t=terrain)\n");
        printf("  -r seed  :: random seed to initialize PRNG\n");
        printf("  -s num   :: floating point number for xyz speed\n");
        printf("  -x num   :: floating point number for x speed\n");
        printf("  -y num   :: floating point number for y speed\n");
        printf("  -z num   :: floating point number for z speed\n");
        printf("  -w num   :: width of frame to generate\n");
        printf("  -h num   :: height of frame to generate\n");
        printf("  -F num   :: initial frequency for first octave\n");
        printf("  -o num   :: number of octaves to compute\n");
        printf("  -p num   :: persistence value for subsequent octaves\n");
        printf("  -n name  :: file name to use for frames\n");
        exit(-1);
    }
  }

  srand(options->seed);
}

int main(int argc, char *argv[]) {
  options_t options;

  parse_options(argc, argv, &options);

  image_t img = image_new(options.width, options.height, 0xffffff);

  perlin_config_t config;
  perlin_config_init(&config, perlin_init());

  config.frequency = options.frequency;
  config.persistence = options.persistence;
  config.octaves = options.octaves;

  for(int i = 0; i < options.frames; i++) {
    char fname[256];

    config.dx = i*options.speed_x;
    config.dy = i*options.speed_y;
    config.dz = i*options.speed_z;

    perlin(img, &config);

    image_normalize(img);
    if (options.color) image_recolor(img, options.color);

    sprintf(fname, options.frame_name, i);
    image_save_ppm(img, fname);
  }

  perlin_destroy(config.state);
  image_destroy(img);
}
