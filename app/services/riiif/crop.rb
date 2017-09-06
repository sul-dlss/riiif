module Riiif
  # Represents a cropping operation
  class Crop
    attr_reader :image_info

    # @return [String] a region for imagemagick to decode
    #                  (appropriate for passing to the -crop parameter)
    def to_imagemagick
      "#{width}x#{height}+#{offset_x}+#{offset_y}"
    end

    # @return [String] a region for kakadu to decode
    #                  (appropriate for passing to the -region parameter)
    def to_kakadu
      "\{#{decimal_offset_y},#{decimal_offset_x}\},\{#{decimal_height},#{decimal_width}\}"
    end

    attr_reader :offset_x

    attr_reader :offset_y

    # @return [Integer] the height in pixels
    def height
      image_info.height
    end

    # @return [Integer] the width in pixels
    def width
      image_info.width
    end

    # @return [Float] the fractional height with respect to the original size
    def decimal_height(n = height)
      n.to_f / image_info.height
    end

    # @return [Float] the fractional width with respect to the original size
    def decimal_width(n = width)
      n.to_f / image_info.width
    end

    def decimal_offset_x
      offset_x.to_f / image_info.width
    end

    def decimal_offset_y
      offset_y.to_f / image_info.height
    end

    def maintain_aspect_ratio?
      (height / width) == (image_info.height / image_info.width)
    end
  end
end
