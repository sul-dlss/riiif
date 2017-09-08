module Riiif
  module Size
    # The width and height of the returned image are exactly w and h.
    # The aspect ratio of the returned image may be different than the extracted
    # region, resulting in a distorted image.
    class Absolute < Resize
      # @param [ImageInformation] info
      # @param [String] width
      # @param [String] height
      def initialize(info, width, height)
        @image_info = info
        @width = width.to_i
        @height = height.to_i
      end

      # @return [String] a resize directive for imagemagick to use
      def to_imagemagick
        "#{@width}x#{@height}!"
      end

      attr_reader :height, :width

      # Reduce this if the aspect ratio of the image is maintained.
      def reduce?
        in_delta?(image_info.aspect_ratio, aspect_ratio, 0.001)
      end

      private

        def aspect_ratio
          width.to_f / height
        end

        def in_delta?(x1, x2, delta)
          (x1 - x2).abs <= delta
        end
    end
  end
end
