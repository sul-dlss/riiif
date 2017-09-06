module Riiif
  module Region
    # Represents an absolute specified region
    class Absolute < Crop
      # TODO: only kakadu needs image_info. So there's potenial to optimize by
      # making image_info a proxy that fetches the info lazily when needed.
      def initialize(image_info, x, y, width, height)
        @image_info = image_info
        @offset_x = x
        @offset_y = y
        @width = width
        @height = height
      end

      attr_reader :width, :height
    end
  end
end
