module Riiif
  module Size
    module Imagemagick
      # The image or region should be scaled so that its height is exactly equal
      # to the provided parameter, and the width will be a calculated value that
      # maintains the aspect ratio of the extracted region
      class HeightDecoder
        def initialize(height)
          @height = height
        end

        # @return [String] a resize directive for imagemagick to use
        def decode
          "x#{@height}"
        end
      end
    end
  end
end
