#![allow(dead_code)]

use std::io::Write;

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
    if x < self.width && y < self.height {
      let index = y * self.width + x;
      self.pixels[index] = color;
    }
  }

  pub fn get_pixel(&self, x: usize, y: usize) -> u32
  {
    if x < self.width && y < self.height {
      let index = y * self.width + x;
      self.pixels[index]
    } else {
      0
    }
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

  // adapted from the discussion and code presented here:
  // http://kt8216.unixcab.org/murphy/index.html
  pub fn draw_thick_line<F>(&mut self,
                            p1: (usize, usize),
                            p2: (usize, usize),
                            color: u32,
                            left_width: F,
                            right_width: F)
    where F: Fn(isize, isize) -> isize
  {
    let (dx, xstep) = if p1.0 > p2.0 {
        (p1.0 as isize - p2.0 as isize, -1)
      } else if p1.0 == p2.0 {
        (0, 0)
      } else {
        (p2.0 as isize - p1.0 as isize, 1)
      };

    let (dy, ystep) = if p1.1 > p2.1 {
        (p1.1 as isize - p2.1 as isize, -1)
      } else if p1.1 == p2.1 {
        (0, 0)
      } else {
        (p2.1 as isize - p1.1 as isize, 1)
      };

    // compute the perpendicular x/y steps
    let (pystep, pxstep, left_fn, right_fn) = match xstep + ystep*4 {
      -5 => (-1,  1, right_width, left_width),  // -1 + -1*4
      -1 => (-1,  0, right_width, left_width),  // -1 +  0*4
       3 => ( 1,  1, left_width,  right_width), // -1 +  1*4
      -4 => ( 0, -1, left_width,  right_width), //  0 + -1*4
       0 => ( 0,  0, left_width,  right_width), //  0 +  0*4
       4 => ( 0,  1, left_width,  right_width), //  0 +  1*4
      -3 => (-1, -1, left_width,  right_width), //  1 + -1*4
       1 => (-1,  0, left_width,  right_width), //  1 +  0*4
       5 => ( 1, -1, right_width, left_width),  //  1 +  1*4
       _ => ( 9,  9, left_width,  right_width),
    };

    if dx > dy {
      self.x_varthick_line(p1, color, dx, dy,
                           xstep, ystep,
                           left_fn, right_fn,
                           pxstep, pystep);
    } else {
      self.y_varthick_line(p1, color, dx, dy,
                           xstep, ystep,
                           left_fn, right_fn,
                           pxstep, pystep);
    }
  }

  fn x_perpendicular(&mut self,
                     p1: (isize, isize),
                     color: u32,
                     dx: isize, dy: isize,
                     xstep: isize, ystep: isize,
                     einit: isize,
                     w_left: isize, w_right: isize,
                     winit: isize)
  {
    let threshold = dx - 2 * dy;
    let e_diag = -2 * dx;
    let e_square = 2 * dy;
    let mut p: isize = 0;
    let mut q: isize = 0;
    let mut x = p1.0;
    let mut y = p1.1;
    let mut error = einit;
    let mut tk = dx + dy - winit;

    while tk <= w_left {
      self.put_pixel(x as usize, y as usize, color);

      if error >= threshold {
        x += xstep;
        error += e_diag;
        tk += 2 * dy;
      }

      error += e_square;
      y += ystep;
      tk += 2 * dx;
      q += 1;
    }

    x = p1.0;
    y = p1.1;
    error = -einit;
    tk = dx + dy + winit;

    while tk <= w_right {
      if p > 0 { self.put_pixel(x as usize, y as usize, color); }

      if error > threshold {
        x -= xstep;
        error += e_diag;
        tk += 2 * dy;
      }

      error += e_square;
      y -= ystep;
      tk += 2 * dx;
      p += 1;
    }

    // for very thin lines
    if q == 0 && p < 2 {
      self.put_pixel(p1.0 as usize, p1.1 as usize, color);
    }
  }

  fn x_varthick_line<F>(&mut self,
                        p1: (usize, usize),
                        color: u32,
                        dx: isize, dy: isize,
                        xstep: isize, ystep: isize,
                        left_width: F,
                        right_width: F,
                        pxstep: isize, pystep: isize)
    where F: Fn(isize, isize) -> isize
  {
    let mut p_error: isize = 0;
    let mut error: isize = 0;
    let mut x = p1.0 as isize;
    let mut y = p1.1 as isize;
    let threshold = dx - 2 * dy;
    let e_diag = -2 * dx;
    let e_square = 2 * dy;
    let length = dx + 1;
    let d = (( dx * dx + dy * dy ) as f64).sqrt();

    for p in 0..length {
      let w_left = ((left_width(p, length) * 2) as f64 * d) as isize;
      let w_right = ((right_width(p, length) * 2) as f64 * d) as isize;
      self.x_perpendicular((x, y), color, dx, dy, pxstep, pystep,
                           p_error, w_left, w_right, error);

      if error >= threshold {
        y += ystep;
        error += e_diag;

        if p_error >= threshold {
          self.x_perpendicular((x, y), color, dx, dy, pxstep, pystep,
                               (p_error+e_diag+e_square),
                               w_left, w_right, error);
          p_error += e_diag;
        }

        p_error += e_square;
      }

      error += e_square;
      x += xstep;
    }
  }

  fn y_perpendicular(&mut self,
                     p1: (isize, isize),
                     color: u32,
                     dx: isize, dy: isize,
                     xstep: isize, ystep: isize,
                     einit: isize,
                     w_left: isize, w_right: isize,
                     winit: isize)
  {
    let threshold = dy - 2 * dx;
    let e_diag = -2 * dy;
    let e_square = 2 * dx;
    let mut p: isize = 0;
    let mut q: isize = 0;
    let mut x = p1.0;
    let mut y = p1.1;
    let mut error = -einit;
    let mut tk = dx + dy + winit;

    while tk <= w_left {
      self.put_pixel(x as usize, y as usize, color);

      if error > threshold {
        y += ystep;
        error += e_diag;
        tk += 2 * dx;
      }

      error += e_square;
      x += xstep;
      tk += 2 * dy;
      q += 1;
    }

    x = p1.0;
    y = p1.1;
    error = einit;
    tk = dx + dy - winit;

    while tk <= w_right {
      if p > 0 { self.put_pixel(x as usize, y as usize, color); }

      if error >= threshold {
        y -= ystep;
        error += e_diag;
        tk += 2 * dx;
      }

      error += e_square;
      x -= xstep;
      tk += 2 * dy;
      p += 1;
    }

    // for very thin lines
    if q == 0 && p < 2 {
      self.put_pixel(p1.0 as usize, p1.1 as usize, color);
    }
  }

  fn y_varthick_line<F>(&mut self,
                        p1: (usize, usize),
                        color: u32,
                        dx: isize, dy: isize,
                        xstep: isize, ystep: isize,
                        left_width: F,
                        right_width: F,
                        pxstep: isize, pystep: isize)
    where F: Fn(isize, isize) -> isize
  {
    let mut p_error: isize = 0;
    let mut error: isize = 0;
    let mut x = p1.0 as isize;
    let mut y = p1.1 as isize;
    let threshold = dy - 2 * dx;
    let e_diag = -2 * dy;
    let e_square = 2 * dx;
    let length = dy + 1;
    let d = (( dx * dx + dy * dy ) as f64).sqrt();

    for p in 0..length {
      let w_left = ((left_width(p, length) * 2) as f64 * d) as isize;
      let w_right = ((right_width(p, length) * 2) as f64 * d) as isize;
      self.y_perpendicular((x, y), color, dx, dy, pxstep, pystep,
                           p_error, w_left, w_right, error);

      if error >= threshold {
        x += xstep;
        error += e_diag;

        if p_error >= threshold {
          self.y_perpendicular((x, y), color, dx, dy, pxstep, pystep,
                               (p_error+e_diag+e_square),
                               w_left, w_right, error);
          p_error += e_diag;
        }

        p_error += e_square;
      }

      error += e_square;
      y += ystep;
    }
  }

  pub fn to_ppm<I: Write>(&self, mut out: I)
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

    let result = out.write_all(buffer.as_bytes());
    if !result.is_ok() {
      println!("could not write image to file");
    }
  }
}
