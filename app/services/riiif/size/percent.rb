module Riiif
  module Size
    # The width and height of the returned image is scaled to n% of the width and height
    # of the extracted region. The aspect ratio of the returned image is the same as that
    # of the extracted region.
    class Percent < Resize
      def initialize(info, percentage)
        @image_info = info
        @percentage = percentage
      end

      attr_reader :percentage

      # @return [String] a resize directive for imagemagick to use
      def to_imagemagick
        "#{percentage}%"
      end

      # @return [Integer] the height in pixels
      def height
        percent_of(image_info.height)
      end

      # @return [Integer] the width in pixels
      def width
        percent_of(image_info.width)
      end

      # @param [Integer] factor number of times to reduce by 1/2
      def reduce(factor)
        pct = percentage.to_f * 2**factor
        Percent.new(image_info, pct)
      end

      private

        # @param [Integer] value a value to convert to the percentage
        # @return [Float]
        def percent_of(value)
          value * Integer(percentage).to_f / 100
        end
    end
  end
end
