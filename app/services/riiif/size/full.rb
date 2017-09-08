module Riiif
  module Size
    # represents requested full size
    class Full < Resize
      # @return [NilClass] a size for imagemagick to decode
      #                    the nil implies no resizing needed
      def to_imagemagick
        nil
      end

      # Should we reduce this image?
      def reduce?
        false
      end
    end
  end
end
