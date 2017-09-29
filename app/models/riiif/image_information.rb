module Riiif
  # This is the result of calling the Riiif.image_info service. It stores the height & width
  class ImageInformation < IIIF::Image::Dimension
    extend Deprecation

    def initialize(*args)
      if args.size == 2
        Deprecation.warn(self, 'calling initialize without kwargs is deprecated. Use height: and width:')
        super(width: args.first, height: args.second)
      else
        super
      end
    end

    def to_h
      { width: width, height: height }
    end

    # Image information is only valid if height and width are present.
    # If an image info service doesn't have the value yet (not characterized perhaps?)
    # then we wouldn't want to cache this value.
    def valid?
      width.present? && height.present?
    end
  end
end
