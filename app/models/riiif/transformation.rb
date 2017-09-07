module Riiif
  # Represents a IIIF request
  class Transformation
    attr_reader :crop, :size, :quality, :rotation, :format
    def initialize(crop, size, quality, rotation, format)
      @crop = crop
      @size = size
      @quality = quality
      @rotation = rotation
      @format = format
    end

    # Create a clone of this Transformation, scaled by the factor
    # @param [Integer] factor the scale for the new transformation
    # @return [Transformation] a new transformation, scaled by factor
    def reduce(factor)
      Transformation.new(crop.dup,
                         size.reduce(factor),
                         quality,
                         rotation,
                         format)
    end

    # Create a clone of this Transformation, without the crop
    # @return [Transformation] a new transformation
    # TODO: it would be nice if we didn't need image_info
    def without_crop(image_info)
      Transformation.new(Region::Full.new(image_info),
                         size.dup,
                         quality,
                         rotation,
                         format)
    end
  end
end
