mod image;

fn main() {
  let mut image = image::Image::new(10, 10, 0);
  image.draw_line((0,0), (9,0), 0xff0000);
  image.draw_line((0,0), (9,5), 0xffff00);
  image.draw_line((0,0), (9,9), 0xff00ff);
  image.draw_line((0,0), (5,9), 0x00ffff);
  image.draw_line((0,0), (0,9), 0x0000ff);
  let ppm = image.to_ppm();
  println!("{}", ppm);
}
