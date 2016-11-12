require 'turtle'

t = Turtle.new(250, 250)

r = 100

t.pen(:up)
t.right(90)
t.move(r)
t.left(120)

t.pen(:down)

count = (r / 5) * 6
intensity = 255.0
inc = (256.0 - 64.0) / count

while r > 0
  6.times do |n|
    t.set_color(ChunkyPNG::Color.rgb(intensity.round, intensity.round, intensity.round))

    dist = if n == 0
        r + 5
      elsif n == 5
        r - 5
      else
        r
      end

    t.move(dist)
    t.left(60)

    intensity -= inc
  end

  r -= 5
end

t.save("hex-spiral.png")
