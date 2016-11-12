require 'turtle'

t = Turtle.new(500, 500)

r = 225
check = 0

while r >= 10
  t.push

  t.pen(:up)
  t.move(r)
  t.left(90)
  t.pen(:down)

  dist = 2 * Math::PI * r / 360

  360.times do |n|
    if (n / 5) % 2 == check
      t.pen(:down)
    else
      t.pen(:up)
    end

    t.move(dist)
    t.left(1)
  end

  r -= 5
  check = 1 - check

  t.pop
end

t.save("circle.png")
