module Riiif
  # Represents a resize operation
  class Resize
    attr_reader :image_info

    # @return [Integer] the height in pixels
    def height
      image_info.height
    end

    # @return [Integer] the width in pixels
    def width
      image_info.width
    end

    # Should we reduce this image with KDU?
    def reduce?
      true
    end

    # This is used for a second resize by imagemagick after resizing
    # by kdu.
    # No need to scale most resize operations (only percent)
    # @param [Integer] factor to scale by
    # @return [Absolute] a copy of self if factor is zero.
    def reduce(_factor)
      dup
    end

    # @return [Integer] the reduction factor for this operation
    def reduction_factor(max_factor = 5)
      return nil unless reduce?
      scale = [width.to_f / image_info.width,
               height.to_f / image_info.height].min
      factor = 0
      raise "I don't know how to scale to #{scale}" if scale > 1
      next_pct = 0.5
      while scale <= next_pct && factor < max_factor
        next_pct /= 2.0
        factor += 1
      end
      factor
    end
  end
end
