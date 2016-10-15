require 'chunky_png'

def circle(canvas, ox, oy, r, color)
  x = r
  y = 0
  err = 1 - r

  while x >= y
    canvas[ox + x, oy + y] = color
    canvas[ox + y, oy + x] = color
    canvas[ox - y, oy + x] = color
    canvas[ox - x, oy + y] = color
    canvas[ox - x, oy - y] = color
    canvas[ox - y, oy - x] = color
    canvas[ox + y, oy - x] = color
    canvas[ox + x, oy - y] = color

    y += 1

    if err <= 0
      err += 2 * y + 1
    else
      x -= 1
      err += 2 * (y - x) + 1
    end
  end
end

image = ChunkyPNG::Image.new(250, 250, 0xffffffff)

50.downto(1) do |i|
  s = 255 - (i - 1) * 5
  c = ChunkyPNG::Color.rgb(255, s, s)
  circle(image, 100, 100, i, c)
end

image.save("circles.png")
