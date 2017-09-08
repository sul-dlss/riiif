module Riiif
  module Region
    # Represents requested square cooridnates
    class Square < Crop
      def initialize(image_info)
        @image_info = image_info
        @min, @max = [@image_info.width, @image_info.height].minmax
        @offset = (@max - @min) / 2
      end

      # @return [String] a square region for imagemagick to decode
      #                  (appropriate for passing to the -crop parameter)
      def to_imagemagick
        if @image_info.height >= @image_info.width
          "#{height}x#{width}+0+#{@offset}"
        else
          "#{height}x#{width}+#{@offset}+0"
        end
      end

      # @return [String] a region for kakadu to decode
      #                  (appropriate for passing to the -region parameter)
      def to_kakadu
        # (top, left, height, width)
        if @image_info.height >= @image_info.width
          # Portrait
          "\{#{decimal_height(@offset)},0\}," \
          "\{#{decimal_height(height)},#{decimal_width(height)}\}"
        else
          # Landscape
          "\{0,#{decimal_width(@offset)}\}," \
          "\{#{decimal_height(width)},#{decimal_width(width)}\}"
        end
      end

      def height
        @min
      end

      def width
        @min
      end
    end
  end
end
