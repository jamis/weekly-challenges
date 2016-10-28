require 'chunky_png'
require 'matrix'

EPSILON = 0.00001

# TODO:
# * Delaunay Triangulation via Bowyer–Watson algorithm
# * compute dual graph of Delaunay triangulation to get Voronoi diagram

class Vector
  def x; self[0]; end
  def y; self[1]; end
end

class Triangulation
  attr_reader :edges
  attr_reader :triangles

  def initialize(points)
    mesh = _init_mesh

    points.each do |point|
      bad = mesh.select { |t| t.circumcircle.contains?(point) }

      polygon = []
      bad.each do |tri|
        tri.edges.each do |edge|
          next if bad.any? { |b| b != tri && b.has_edge?(*edge) }
          polygon << edge
        end
      end

      bad.each { |tri| mesh.delete(tri) }

      polygon.each do |edge|
        new_tri = Triangle.new(edge[0], edge[1], point)
        mesh.push(new_tri)
      end
    end

    mesh.delete_if { |tri| @bounds.any? { |v| tri.has_vertex?(v) } }

    @triangles = mesh

    @triangles_by_point = {}
    mesh.each do |tri|
      (@triangles_by_point[tri.a] ||= []) << tri
      (@triangles_by_point[tri.b] ||= []) << tri
      (@triangles_by_point[tri.c] ||= []) << tri
    end

    @edges = mesh.flat_map { |tri| tri.edges }.uniq
    @points = points
  end

  # compares a and b, relative to the center point c.
  # returns true if a is less than b, false otherwise.
  # algorithm taken from here:
  #   http://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
  def _compare(c, a, b)
    return true  if a.x - c.x >= 0 && b.x - c.x < 0
    return false if a.x - c.x < 0 && b.x - c.x >= 0

    if a.x - c.x == 0 && b.x - c.x == 0
      return a.y > b.y if a.y - c.y >= 0 || b.y - c.y >= 0
      return b.y > a.y
    end

    det = (a.x - c.x) * (b.y - c.y) - (b.x - c.x) * (a.y - c.y)
    return true if det < 0
    return false if det > 0

    d1 = (a.x - c.x)**2 + (a.y - c.y)**2
    d2 = (b.x - c.x)**2 + (b.y - c.y)**2
    return d1 > d2
  end

  def to_voronoi
    polygons = []

    # each point will form the center of a voronoi polygon
    @points.each do |point|
      triangles = @triangles_by_point[point]
      vertices = triangles.
        map { |t| t.circumcircle.p }.
        sort { |a,b| _compare(point, a, b) ? -1 : 1 }
      polygons << { point: point, vertices: vertices }
    end

    polygons
  end

  def _init_mesh
    minx = miny = 1_000_000
    maxx = maxy = -minx

    a = Vector[minx, miny, 0]
    b = Vector[maxx, miny, 0]
    c = Vector[maxx, maxy, 0]
    d = Vector[minx, maxy, 0]

    tri1 = Triangle.new(a, b, c)
    tri2 = Triangle.new(a, d, c)

    @bounds = [a, b, c, d]

    [tri1, tri2]
  end
end

class PoissonDiscSampling
  attr_reader :width, :height
  attr_reader :r, :k
  attr_reader :cell_size

  attr_reader :samples

  attr_reader :grid_width, :grid_height

  def initialize(width, height, r, k)
    @width, @height = width, height
    @r, @k = r, k

    r2 = r * r
    @cell_size = r / Math.sqrt(2)

    @grid_width = ( width / cell_size ).ceil
    @grid_height = ( height / cell_size ).ceil

    @grid = Array.new(@grid_height) { Array.new(@grid_width) }

    @samples = []
    active_samples = []

    x = rand(width)
    y = rand(height)

    gx = (x / cell_size).floor
    gy = (y / cell_size).floor

    @samples << Vector[x,y,0]
    active_samples << @samples.length-1
    @grid[gy][gx] = @samples.length-1

    while active_samples.any?
      index = rand(active_samples.length)
      sample = @samples[active_samples[index]]
      dead = true

      k.times do
        angle = Math::PI * rand(360) / 180.0
        d = r + rand(r)

        x = (sample.x + Math.cos(angle) * d).floor
        next if x < 0 || x >= width
        y = (sample.y - Math.sin(angle) * d).floor
        next if y < 0 || y >= height

        gx = (x / cell_size).floor
        gy = (y / cell_size).floor
        okay = true

        (gy-1).upto(gy+1) do |cy|
          next if cy < 0 || cy >= @grid_height
          (gx-1).upto(gx+1) do |cx|
            next if cx < 0 || cx >= @grid_width

            if @grid[cy][cx]
              t = @samples[@grid[cy][cx]]
              dist = (t.x - x) * (t.x - x) + (t.y - y) * (t.y - y)
              if dist <= r2
                okay = false
                break
              end
            end
          end

          break unless okay
        end

        if okay
          @samples << Vector[x, y, 0]
          active_samples << @samples.length-1
          @grid[gy][gx] = @samples.length-1
          dead = false
          break
        end
      end

      active_samples.delete_at(index) if dead
    end
  end

  def [](x, y)
    index = @grid[y][x]
    index && @samples[index] ||
      Vector[
        (x * @cell_size).floor,
        (y * @cell_size).floor,
        0 ]
  end
end

class Triangle
  attr_reader :a, :b, :c

  # a, b, c must be Vector instances
  def initialize(a, b, c)
    @a, @b, @c = [a, b, c].sort_by { |v| [v.x, v.y] }
  end

  def has_edge?(p1, p2)
    return true if p1 == a && p2 == b || p1 == b && p2 == a
    return true if p1 == b && p2 == c || p1 == c && p2 == b
    return true if p1 == c && p2 == a || p1 == a && p2 == c
    false
  end

  def has_vertex?(v)
    a == v || b == v || c == v
  end

  def edges
    @_edges ||= [[a,b], [b,c], [a,c]]
  end

  def circumcircle
    @_circumcircle ||= begin
      ab = a - b; abm = ab.magnitude
      ba = b - a
      bc = b - c; bcm = bc.magnitude
      ca = c - a; cam = ca.magnitude
      cb = c - b
      ac = a - c; acm = ac.magnitude

      r = abm * bcm * cam / (2 * ab.cross(bc).magnitude)

      denom = 2 * ab.cross(bc).magnitude ** 2
      alpha = bcm * bcm * ab.dot(ac) / denom
      beta  = acm * acm * ba.dot(bc) / denom
      gamma = abm * abm * ca.dot(cb) / denom

      p = a * alpha + b * beta + c * gamma

      Circle.new(p, r)
    end
  end
end

class Circle
  attr_reader :p, :r

  def initialize(p, r)
    @p, @r = p, r
  end

  def contains?(p2)
    dx = (p2.x - p.x) ** 2
    dy = (p2.y - p.y) ** 2
    dx + dy - r * r <= EPSILON
  end
end

class SampleImage < ChunkyPNG::Image
  def draw_samples(sampling, color)
    sampling.samples.each do |p|
      self[p.x, p.y] = color
    end
  end

  def draw_triangulation(sampling, color)
    samples = sampling.samples.dup

    dx = (width-1) / 10.0
    dy = (height-1) / 10.0
    11.times do |i|
      y = (i * dy).to_i
      x = (i * dx).to_i

      samples.push(Vector[0, y, 0])
      samples.push(Vector[width-1, y, 0])
      samples.push(Vector[x, 0, 0])
      samples.push(Vector[x, height-1, 0])
    end

    triangulation = Triangulation.new(samples)

    triangulation.edges.each do |edge|
      line(edge[0].x, edge[0].y, edge[1].x, edge[1].y, color)
    end
  end

  def draw_voronoi(sampling, color)
    triangulation = Triangulation.new(sampling.samples)
    polygons = triangulation.to_voronoi

    polygons.each do |poly|
      next if poly[:vertices].count < 3
      polygon(poly[:vertices], color)
    end
  end

  def resample(r, k)
    sampling = PoissonDiscSampling.new(width, height, r, k)

    new_image = self.class.new(sampling.grid_width, sampling.grid_height, ChunkyPNG::Color::WHITE)
    sampling.grid_height.times do |y|
      sampling.grid_width.times do |x|
        p = sampling[x, y]
        new_image[x, y] = self[p.x, p.y]
      end
    end

    new_image
  end

  def voronoi_tiles(r, k)
    sampling = PoissonDiscSampling.new(width, height, r, k)
    triangulation = Triangulation.new(sampling.samples)
    polygons = triangulation.to_voronoi

    new_image = self.class.new(width, height, ChunkyPNG::Color::WHITE)

    polygons.each do |poly|
      color = self[poly[:point].x, poly[:point].y]
      new_image.polygon(poly[:vertices], ChunkyPNG::Color::BLACK, color)
    end

    new_image
  end
end

sampling = PoissonDiscSampling.new(256, 256, 16, 50)
i = SampleImage.new(256, 256, ChunkyPNG::Color::WHITE)

i.draw_samples(sampling, ChunkyPNG::Color.rgb(255, 0, 0))
i.save("poisson.png")

i.draw_triangulation(sampling, ChunkyPNG::Color.rgb(255, 127, 127))
i.save("triangulation.png")

i = SampleImage.new(256, 256, ChunkyPNG::Color::WHITE)
i.draw_samples(sampling, ChunkyPNG::Color.rgb(255, 0, 0))
i.draw_voronoi(sampling, ChunkyPNG::Color.rgb(255, 128, 128))
i.save("voronoi.png")

if ARGV.any?
  i = SampleImage.from_file(ARGV.first)
  i.resample(10, 20).save("resampled.png")

  i.voronoi_tiles(24, 50).save("voronoi_tiles.png")
end
