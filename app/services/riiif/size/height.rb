module Riiif
  module Size
    # The image or region should be scaled so that its height is exactly equal
    # to the provided parameter, and the width will be a calculated value that
    # maintains the aspect ratio of the extracted region
    class Height < Resize
      def initialize(info, height)
        @image_info = info
        @height = height
      end

      # @return [String] a resize directive for imagemagick to use
      def to_imagemagick
        "x#{@height}"
      end

      def width
        height * image_info.width / image_info.height
      end

      attr_reader :height
    end
  end
end
