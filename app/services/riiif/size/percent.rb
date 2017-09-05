module Riiif
  module Size
    # The width and height of the returned image is scaled to n% of the width and height
    # of the extracted region. The aspect ratio of the returned image is the same as that
    # of the extracted region.
    class Percent
      def initialize(n)
        @n = n
      end

      # @return [String] a resize directive for imagemagick to use
      def to_imagemagick
        "#{@n}%"
      end
    end
  end
end
