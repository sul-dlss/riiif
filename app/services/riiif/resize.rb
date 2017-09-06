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

    # @param [Crop] reduced_size
    # @return [Integer] the reduction factor for this operation
    def reduction_factor(reduced_size, max_factor = 5)
      return nil unless reduce?
      scale = [width.to_f / reduced_size.width,
               height.to_f / reduced_size.height].min
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
