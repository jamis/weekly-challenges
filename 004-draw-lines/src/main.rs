extern crate rand;

mod image;
use std::fs::File;
use std::error::Error;

fn main() {
  let mut image = image::Image::new(503, 503, 0xffffff);
  let (width, height) = image.dimensions();
  let options = image::LineOptions::default().with_width(6);

  let mut x = 1;
  while x < width-1 {
    //let color = rand::random::<u32>();
    let intensity = (255 * (x - 1) / (width - 2)) as u32;
    let color = 0xff0000 +
                (intensity << 8) +
                intensity;

    let options = options.with_color(color);

    //image.draw_line((x,1), (width-2,x), color);
    //image.draw_line((width-2,x), (width-x,height-2), color);
    //image.draw_line((width-x,height-2), (1,width-x), color);
    //image.draw_line((1,width-x), (x,1), color);

    image.draw_line((x,1), (width-2,x), &options);
    image.draw_line((width-2,x), (width-x,height-2), &options);
    image.draw_line((width-x,height-2), (1,width-x), &options);
    image.draw_line((1,width-x), (x,1), &options);

    x += 10;
  }

  // dotted line
  let dotted = image::LineOptions::default().with_color(0xff0000).with_dash(1);
  image.draw_line((50,200), (450,200), &dotted);
  image.draw_line((50,210), (450,210), &dotted.with_width(3));

  let dashed = image::LineOptions::default().with_color(0x0000ff).with_dash(5);
  image.draw_line((50,300), (450,300), &dashed);
  image.draw_line((50,310), (450,310), &dashed.with_width(3));

  match File::create("lines.ppm") {
    Err(why) => println!("couldn't create lines.ppm ({})", why.description()),
    Ok(file) => image.to_ppm(file)
  };
}
