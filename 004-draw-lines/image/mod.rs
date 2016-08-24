pub struct Image {
  width: usize,
  height: usize,
  pixels: Vec<u32>,
}

impl Image {
  pub fn new(width: usize, height: usize, background: u32) -> Image
  {
    let size = width * height;
    let pixels = vec![background; size];

    Image { width: width, height: height, pixels: pixels }
  }

  pub fn dimensions(&self) -> (usize, usize)
  {
    (self.width, self.height)
  }

  pub fn put_pixel(&mut self, x: usize, y: usize, color: u32)
  {
    let index = y * self.width + x;
    self.pixels[index] = color;
  }

  pub fn get_pixel(&self, x: usize, y: usize) -> u32
  {
    let index = y * self.width + x;
    self.pixels[index]
  }

  fn preferred_grade((x1, y1): (usize, usize), (x2, y2): (usize, usize)) -> (bool, (usize, usize), (usize, usize))
  {
    let dx = x2 as isize - x1 as isize;
    let dy = y2 as isize - y1 as isize;
    let steep = dy.abs() > dx.abs();

    if steep {
      (true, (y1, x1), (y2, x2))
    } else {
      (false, (x1, y1), (x2, y2))
    }
  }

  fn ascending_order((x1, y1): (usize, usize), (x2, y2): (usize, usize)) -> ((usize, usize), (usize, usize))
  {
    if x1 > x2 {
      ((x2, y2), (x1, y1))
    } else {
      ((x1, y1), (x2, y2))
    }
  }

  fn normalize_coordinates(p1: (usize, usize), p2: (usize, usize)) -> (bool, (usize, usize), (usize, usize))
  {
    let (steep, p1, p2) = Image::preferred_grade(p1, p2);
    let (p1, p2) = Image::ascending_order(p1, p2);
    (steep, p1, p2)
  }

  pub fn draw_line(&mut self, p1: (usize, usize), p2: (usize, usize), color: u32)
  {
    let (steep, (x1, y1), (x2, y2)) = Image::normalize_coordinates(p1, p2);
    let dx = x2 as isize - x1 as isize;
    let dy = (y2 as isize - y1 as isize).abs();
    let mut error = dx / 2;
    let mut y = y1 as isize;
    let step: isize = if y1 < y2 { 1 } else { -1 };

    for x in x1..(x2+1) {
      if steep {
        self.put_pixel(y as usize, x, color);
      } else {
        self.put_pixel(x, y as usize, color);
      }

      error -= dy;
      if error < 0 {
        y += step;
        error += dx;
      }
    }
  }

  pub fn to_ppm(&self) -> String
  {
    let mut buffer = String::from("P3\n");
    let header = format!("{} {}\n255\n", self.width, self.height);
    buffer.push_str(header.as_str());

    for y in 0..self.height {
      for x in 0..self.width {
        let pixel = self.get_pixel(x, y);
        let red   = (pixel >> 16) & 0xFF;
        let green = (pixel >> 8) & 0xFF;
        let blue  = pixel & 0xFF;
        if x > 0 { buffer.push(' '); }
        buffer.push_str(format!("{:3} {:3} {:3}", red, green, blue).as_str());
      }
      buffer.push('\n');
    }

    buffer
  }
}
