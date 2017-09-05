module Riiif
  module Size
    # The width and height of the returned image are exactly w and h.
    # The aspect ratio of the returned image may be different than the extracted
    # region, resulting in a distorted image.
    class Absolute
      def initialize(width, height)
        @width = width
        @height = height
      end

      # @return [String] a resize directive for imagemagick to use
      def to_imagemagick
        "#{@width}x#{@height}!"
      end
    end
  end
end
