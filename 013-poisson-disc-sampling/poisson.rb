require 'chunky_png'

class PoissonDiscSampling
  attr_reader :width, :height
  attr_reader :r, :k

  attr_reader :samples

  attr_reader :grid_width, :grid_height

  def initialize(width, height, r, k)
    @width, @height = width, height
    @r, @k = r, k

    r2 = r * r
    cell_size = r / Math.sqrt(2)

    grid_width = ( width / cell_size ).ceil
    grid_height = ( height / cell_size ).ceil

    @grid = Array.new(grid_height) { Array.new(grid_width) }

    @samples = []
    active_samples = []

    x = rand(width)
    y = rand(height)

    gx = (x / cell_size).floor
    gy = (y / cell_size).floor

    @samples << [x,y]
    active_samples << @samples.length-1
    @grid[gy][gx] = @samples.length-1

    while active_samples.any?
      index = rand(active_samples.length)
      sample = @samples[active_samples[index]]
      dead = true

      k.times do
        angle = Math::PI * rand(360) / 180.0
        d = r + rand(r)

        x = (sample[0] + Math.cos(angle) * d).floor
        next if x < 0 || x >= width
        y = (sample[1] - Math.sin(angle) * d).floor
        next if y < 0 || y >= height

        gx = (x / cell_size).floor
        gy = (y / cell_size).floor
        okay = true

        (gy-1).upto(gy+1) do |cy|
          next if cy < 0 || cy >= grid_height
          (gx-1).upto(gx+1) do |cx|
            next if cx < 0 || cx >= grid_width

            if @grid[cy][cx]
              tx, ty = @samples[@grid[cy][cx]]
              dist = (tx - x) * (tx - x) + (ty - y) * (ty - y)
              if dist <= r2
                okay = false
                break
              end
            end
          end

          break unless okay
        end

        if okay
          @samples << [x, y]
          active_samples << @samples.length-1
          @grid[gy][gx] = @samples.length-1
          dead = false
          break
        end
      end

      active_samples.delete_at(index) if dead
    end
  end
end

class SampleImage < ChunkyPNG::Image
  def draw_samples(r, k, color)
    sampling = PoissonDiscSampling.new(width, height, r, k)
    sampling.samples.each do |(x, y)|
      self[x, y] = color
    end
  end
end

i = SampleImage.new(256, 256, ChunkyPNG::Color::WHITE)

i.draw_samples(10, 50, ChunkyPNG::Color.rgb(255, 0, 0))
i.save("poisson.png")
