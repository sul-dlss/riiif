module Riiif
  module Region
    module Imagemagick
      # The image or region is not scaled, and is returned at its full size.
      class FullDecoder
        # @return [NilClass] a region for imagemagick to decode
        #                    the nil implies no cropping needed
        def decode
          nil
        end
      end
    end
  end
end
