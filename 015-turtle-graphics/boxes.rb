require 'turtle'

t = Turtle.new(250, 250)

30.times do |n|
  i = 128 + 128 * n / 30
  t.set_color ChunkyPNG::Color.rgb(i,i,i)
  t.pen(:up)
  t.move(10)
  t.pen(:down)

  4.times do
    t.move(50)
    t.right(90)
  end

  t.pen(:up)
  t.move(-10)
  t.pen(:down)

  t.right(12)

  t.save("turtle-%02d.png" % n)
end
