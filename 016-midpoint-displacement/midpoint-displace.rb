require 'chunky_png'

def midpoint_displace(startp, endp, max, falloff, points, countdown=4)
  return if countdown < 1

  dx    = endp[0] - startp[0]
  dy    = endp[1] - startp[1]
  mag   = dx * dx + dy * dy
  dist  = Math.sqrt(mag)

  midpx = startp[0] + dx / 2.0
  midpy = startp[1] + dy / 2.0

  d = max * (rand() * 2 - 1)

  newy = midpy + d

  midpoint_displace(startp, [midpx, newy], max*falloff, falloff, points, countdown-1)
  points.push([midpx, newy])
  midpoint_displace([midpx, newy], endp, max*falloff, falloff, points, countdown-1)

  points
end

def history_from(points)
  lines = [[0, points.length-1]]

  while lines.last[1] - lines.last[0] > 1
    line = lines.last
    break if line[1] - line[0] == 1

    new_line = [ line[0] ]
    line[1..-1].each do |i|
      s = new_line.last
      m = s + (i - s) / 2
      new_line.push m
      new_line.push i
    end

    lines.push new_line
  end

  lines
end

startp = [20,40]
endp   = [180,40]

srand(5)

points = midpoint_displace(startp, endp, 50.0, 0.5, [startp], 6)
points.push(endp)
history = history_from(points)

history.each_with_index do |indexes, n|
  image = ChunkyPNG::Image.new(200, 60, ChunkyPNG::Color::WHITE)
  sa, sb = points[indexes.shift]
  indexes.each do |i|
    a, b = points[i]
    image.line(sa.round, sb.round, a.round, b.round, ChunkyPNG::Color::BLACK)
    sa, sb = a, b
  end

  image.save("20161112-fractal-%02d.png" % (n+1))
end
