require 'chunky_png'
require 'digest'
require 'thread'

WIDTH = 320
HEIGHT = 240
ITERATIONS = 100
THREADS = 4

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

# Workaround for thread safety issues in SortedSet initialization
# See: https://github.com/celluloid/timers/issues/20
SortedSet.new

chunk_size = ITERATIONS / THREADS

threads = THREADS.times.map do
  Thread.new do
    chunk_size.times do
      image = ChunkyPNG::Image.random(WIDTH, HEIGHT)
      hash = Digest::SHA256.hexdigest(image.to_blob)
      image.save("images/#{hash}.png")
    end
  end
end

threads.map(&:join)
