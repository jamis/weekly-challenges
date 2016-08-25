extern crate rand;

mod image;
use std::fs::File;
use std::error::Error;

fn main() {
  let mut image = image::Image::new(503, 503, 0xffffff);
  let (width, height) = image.dimensions();

  let mut x = 1;
  while x < width-1 {
    //let color = rand::random::<u32>();
    let intensity = (255 * (x - 1) / (width - 2)) as u32;
    let color = 0xff0000 +
                (intensity << 8) +
                intensity;

    //image.draw_line((x,1), (width-2,x), color);
    //image.draw_line((width-2,x), (width-x,height-2), color);
    //image.draw_line((width-x,height-2), (1,width-x), color);
    //image.draw_line((1,width-x), (x,1), color);

    image.draw_thick_line((x,1), (width-2,x), color, 6);
    image.draw_thick_line((width-2,x), (width-x,height-2), color, 6);
    image.draw_thick_line((width-x,height-2), (1,width-x), color, 6);
    image.draw_thick_line((1,width-x), (x,1), color, 6);

    x += 10;
  }

  match File::create("lines.ppm") {
    Err(why) => println!("couldn't create lines.ppm ({})", why.description()),
    Ok(file) => image.to_ppm(file)
  };
}
