module Riiif
  module Size
    # represents requested full size
    class Full
      # @return [NilClass] a size for imagemagick to decode
      #                    the nil implies no resizing needed
      def to_imagemagick
        nil
      end
    end
  end
end
