module Riiif
  module Region
    module Imagemagick
      # decodes requested cooridnates into an imagemagick crop directive
      class SquareDecoder
        def initialize(image_info)
          @image_info = image_info
        end

        # @return [String] a square region for imagemagick to decode
        #                  (appropriate for passing to the -crop parameter)
        def decode
          min, max = [@image_info.width, @image_info.height].minmax

          offset = (max - min) / 2
          if @image_info.height >= @image_info.width
            "#{min}x#{min}+0+#{offset}"
          else
            "#{min}x#{min}+#{offset}+0"
          end
        end
      end
    end
  end
end
