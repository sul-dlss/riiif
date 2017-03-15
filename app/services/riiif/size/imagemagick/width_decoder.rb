module Riiif
  module Size
    module Imagemagick
      # The image or region should be scaled so that its width is exactly equal
      # to the provided parameter, and the height will be a calculated value that
      # maintains the aspect ratio of the extracted region
      class WidthDecoder
        def initialize(width)
          @width = width
        end

        # @return [String] a resize directive for imagemagick to use
        def decode
          @width.to_s
        end
      end
    end
  end
end
