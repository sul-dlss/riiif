module Riiif
  module Size
    module Imagemagick
      # The width and height of the returned image is scaled to n% of the width and height
      # of the extracted region. The aspect ratio of the returned image is the same as that
      # of the extracted region.
      class PercentDecoder
        def initialize(n)
          @n = n
        end

        # @return [String] a resize directive for imagemagick to use
        def decode
          "#{@n}%"
        end
      end
    end
  end
end
