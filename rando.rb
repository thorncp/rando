require 'chunky_png'
require 'digest'

WIDTH = 320
HEIGHT = 240
ITERATIONS = 100

module ChunkyPNG::Color
  def self.random
    rgb(random_value, random_value, random_value)
  end

  private

  def self.random_value
    rand(range)
  end

  def self.range
    @range ||= 0..255
  end
end

class ChunkyPNG::Image
  def self.random(width, height)
    image = ChunkyPNG::Image.new(width, height)

    width.times do |w|
      height.times do |h|
        image[w, h] = ChunkyPNG::Color.random
      end
    end

    image
  end
end

ITERATIONS.times do
  image = ChunkyPNG::Image.random(WIDTH, HEIGHT)
  hash = Digest::SHA256.hexdigest(image.to_blob)
  image.save("images/#{hash}.png")
end
