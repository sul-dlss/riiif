module Riiif
  module Region
    # represents request cooridnates specified as percentage
    class Percentage
      def initialize(image_info, x, y, width, height)
        @image_info = image_info
        @x = x
        @y = y
        @width = width
        @height = height
      end

      # Imagemagick can't do percentage offsets, so we have to calculate it
      # @return [String] a region for imagemagick to decode
      #                  (appropriate for passing to the -crop parameter)
      def to_imagemagick
        "#{@width}%x#{@height}+#{offset_x}+#{offset_y}"
      end

      private

        def offset_x
          (@image_info.width * Integer(@x).to_f / 100).round
        end

        def offset_y
          (@image_info.height * Integer(@y).to_f / 100).round
        end
    end
  end
end
