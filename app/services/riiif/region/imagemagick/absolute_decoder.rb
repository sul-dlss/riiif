module Riiif
  module Region
    module Imagemagick
      # decodes requested cooridnates into an imagemagick crop directive
      class AbsoluteDecoder
        def initialize(x, y, width, height)
          @x = x
          @y = y
          @width = width
          @height = height
        end

        # @return [String] a region for imagemagick to decode
        #                  (appropriate for passing to the -crop parameter)
        def decode
          "#{@width}x#{@height}+#{@x}+#{@y}"
        end
      end
    end
  end
end
