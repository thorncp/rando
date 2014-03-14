require 'chunky_png'
require 'digest'
require 'thread'
require 'optparse'
require 'ostruct'

options = OpenStruct.new(width: 320, height: 240, iterations: 100, threads: 4)

OptionParser.new do |opts|
  opts.banner = "Usage: ruby #{__FILE__} [options]"

  opts.on("-w", "--width WIDTH", Integer, "Image width. Defaults to #{options.width}.") do |width|
    options.width = width
  end

  opts.on("-h", "--height HEIGHT", Integer, "Image height. Defaults to #{options.height}.") do |height|
    options.height = height
  end

  opts.on("-i", "--iterations ITERATIONS", Integer, "Number of images to generate. Defaults to #{options.iterations}.") do |iterations|
    options.iterations = iterations
  end

  opts.on("-t", "--threads THREADS", Integer, "Number of threads to use. Defaults to #{options.threads}.") do |threads|
    options.threads = threads
  end

  opts.on_tail("--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

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

chunk_size = options.iterations / options.threads

threads = options.threads.times.map do
  Thread.new do
    chunk_size.times do
      image = ChunkyPNG::Image.random(options.width, options.height)
      hash = Digest::SHA256.hexdigest(image.to_blob)
      image.save("images/#{hash}.png")
    end
  end
end

threads.map(&:join)
