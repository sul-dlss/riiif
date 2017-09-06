module Riiif
  module Region
    # represents request cooridnates specified as percentage
    class Percentage < Crop
      def initialize(image_info, x, y, width, height)
        @image_info = image_info
        @x_pct = x
        @y_pct = y
        @width_pct = width
        @height_pct = height
      end

      # From the Imagemagick docs:
      #   The percentage symbol '%' can appear anywhere in a argument, and if
      #   given will refer to both width and height numbers. It is a flag that
      #   just declares that the 'image size' parts are a percentage fraction
      #   of the images virtual canvas or page size. Offsets are always given
      #   in pixels.
      # @return [String] a region for imagemagick to decode
      #                  (appropriate for passing to the -crop parameter)
      def to_imagemagick
        "#{@width_pct}%x#{@height_pct}+#{offset_x}+#{offset_y}"
      end

      def maintain_aspect_ratio?
        @width_pct == @height_pct
      end

      private

        # @param [String] n a percentage to convert
        # @return [Float]
        def percentage_to_fraction(n)
          Integer(n).to_f / 100
        end

        # @return [Integer]
        def offset_x
          (@image_info.width * percentage_to_fraction(@x_pct)).round
        end

        # @return [Integer]
        def offset_y
          (@image_info.height * percentage_to_fraction(@y_pct)).round
        end

        # @return [Float]
        def decimal_height
          percentage_to_fraction(@height_pct)
        end

        # @return [Float]
        def decimal_width
          percentage_to_fraction(@width_pct)
        end

        # @return [Float]
        def decimal_offset_y
          percentage_to_fraction(@y_pct)
        end

        # @return [Float]
        def decimal_offset_x
          percentage_to_fraction(@x_pct)
        end
    end
  end
end
