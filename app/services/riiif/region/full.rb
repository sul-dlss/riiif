module Riiif
  module Region
    # Represents the image or region requested at its full size.
    class Full
      # @return [NilClass] a region for imagemagick to decode
      #                    the nil implies no cropping needed
      def to_imagemagick
        nil
      end
    end
  end
end
