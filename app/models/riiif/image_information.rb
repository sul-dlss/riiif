module Riiif
  # This is the result of calling the Riiif.image_info service. It stores the height & width
  class ImageInformation
    def initialize(width, height)
      @width = width
      @height = height
    end

    attr_reader :width, :height

    def to_h
      { width: width, height: height }
    end

    # Image information is only valid if height and width are present.
    # If an image info service doesn't have the value yet (not characterized perhaps?)
    # then we wouldn't want to cache this value.
    def valid?
      width.present? && height.present?
    end

    def ==(other)
      other.class == self.class &&
        other.width == width &&
        other.height == height
    end
  end
end
