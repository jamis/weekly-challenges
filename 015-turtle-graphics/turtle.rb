require 'chunky_png'

class Turtle
  attr_reader :width, :height
  attr_reader :x, :y
  attr_reader :heading
  attr_reader :pen
  attr_reader :color

  def initialize(width, height)
    @width, @height = width, height
    @canvas = ChunkyPNG::Image.new(@width, @height, 0xffffffff)

    @x = width / 2
    @y = height / 2

    @heading = 0.0

    @pen = :down

    @color = 0x000000ff
    @stack = []
  end

  def right(degrees)
    @heading += degrees
  end

  def left(degrees)
    @heading -= degrees
  end

  def pen(upOrDown)
    @pen = upOrDown
  end

  def set_color(color)
    @color = color
  end

  def push
    @stack.push [ @color, @pen, @heading, @x, @y ]
  end

  def pop
    raise "cannot pop empty stack!" if @stack.empty?
    @color, @pen, @heading, @x, @y = @stack.pop
  end

  def move(distance)
    rads = @heading / 180.0 * Math::PI

    dx = distance * Math.sin(rads)
    dy = distance * Math.cos(rads)

    new_x = @x + dx
    new_y = @y - dy

    if @pen == :down
      @canvas.line(@x.round, @y.round, new_x.round, new_y.round, @color)
    end

    @x, @y = new_x, new_y
  end

  def save(name)
    @canvas.save(name)
  end
end
