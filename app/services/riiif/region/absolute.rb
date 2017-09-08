module Riiif
  module Region
    # Represents an absolute specified region
    class Absolute < Crop
      # TODO: only kakadu needs image_info. So there's potenial to optimize by
      # making image_info a proxy that fetches the info lazily when needed.
      # @param [ImageInformation] image_info
      # @param [String] x
      # @param [String] y
      # @param [String] width
      # @param [String] height
      def initialize(image_info, x, y, width, height)
        @image_info = image_info
        @offset_x = x.to_i
        @offset_y = y.to_i
        @width = width.to_i
        @height = height.to_i
      end

      attr_reader :width, :height
    end
  end
end
