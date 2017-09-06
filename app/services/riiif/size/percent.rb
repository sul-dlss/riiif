module Riiif
  module Size
    # The width and height of the returned image is scaled to n% of the width and height
    # of the extracted region. The aspect ratio of the returned image is the same as that
    # of the extracted region.
    class Percent < Resize
      def initialize(info, n)
        @image_info = info
        @n = n
      end

      # @return [String] a resize directive for imagemagick to use
      def to_imagemagick
        "#{@n}%"
      end

      # @return [Integer] the height in pixels
      def height
        percent_of(image_info.height)
      end

      # @return [Integer] the width in pixels
      def width
        percent_of(image_info.width)
      end

      # Should we reduce this image?
      def reduce?
        true
      end

      private

        # @param [Integer] value a value to convert to the percentage
        # @return [Float]
        def percent_of(value)
          value * Integer(@n).to_f / 100
        end
    end
  end
end
