module Riiif
  module Size
    # The image content is scaled for the best fit such that the resulting width and
    # height are less than or equal to the requested width and height.
    class BestFit
      def initialize(width, height)
        @width = width
        @height = height
      end

      # @return [String] a resize directive for imagemagick to use
      def to_imagemagick
        "#{@width}x#{@height}"
      end
    end
  end
end
