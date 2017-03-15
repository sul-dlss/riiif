module Riiif
  module Size
    module Imagemagick
      # decodes requested size into an imagemagick resize directive
      class FullDecoder
        # @return [NilClass] a size for imagemagick to decode
        #                    the nil implies no resizing needed
        def decode
          nil
        end
      end
    end
  end
end
