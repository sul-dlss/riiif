module Riiif
  module Region
    # Represents an absolute specified region
    class Absolute
      def initialize(x, y, width, height)
        @x = x
        @y = y
        @width = width
        @height = height
      end

      # @return [String] a region for imagemagick to decode
      #                  (appropriate for passing to the -crop parameter)
      def to_imagemagick
        "#{@width}x#{@height}+#{@x}+#{@y}"
      end
    end
  end
end
