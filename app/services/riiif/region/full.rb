module Riiif
  module Region
    # Represents the image or region requested at its full size.
    # This is a nil crop operation.
    class Full < Crop
      def initialize(image_info)
        @image_info = image_info
      end

      # @return [NilClass] a region for imagemagick to decode
      #                    the nil implies no cropping needed
      def to_imagemagick
        nil
      end

      # @return [NilClass] a region for kakadu to decode
      #                    the nil implies no cropping needed
      def to_kakadu
        nil
      end
    end
  end
end
