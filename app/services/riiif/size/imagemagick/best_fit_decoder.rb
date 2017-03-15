module Riiif
  module Size
    module Imagemagick
      # The image content is scaled for the best fit such that the resulting width and
      # height are less than or equal to the requested width and height.
      class BestFitDecoder
        def initialize(width, height)
          @width = width
          @height = height
        end

        # @return [String] a resize directive for imagemagick to use
        def decode
          "#{@width}x#{@height}"
        end
      end
    end
  end
end
