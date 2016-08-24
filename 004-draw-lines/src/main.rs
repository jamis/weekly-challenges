extern crate rand;

mod image;

fn main() {
  let mut image = image::Image::new(503, 503, 0xffffff);
  let (width, height) = image.dimensions();

  let mut x = 1;
  while x < width-1 {
    let color = rand::random::<u32>();

    image.draw_line((x,1), (width-2,x), color);
    image.draw_line((width-2,x), (width-x,height-2), color);
    image.draw_line((width-x,height-2), (1,width-x), color);
    image.draw_line((1,width-x), (x,1), color);
    x += 10;
  }

  let ppm = image.to_ppm();
  println!("{}", ppm);
}
