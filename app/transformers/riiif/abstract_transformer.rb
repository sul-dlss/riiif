module Riiif
  # Transforms and returns an image
  class AbstractTransformer
    # @param path [String] The path of the source image file (required only for filesystem-based transformers)
    # @param image_info [ImageInformation] information about the source
    # @param [IIIF::Image::Transformation] transformation
    # @param [String] the Riiif::Image ID
    def self.transform(path: nil, image_info:, transformation:, id: nil)
      new(path: path, image_info: image_info, transformation: transformation, id: id).transform
    end

    def initialize(path:, image_info:, transformation:, id: nil)
      @path = path
      @image_info = image_info
      @transformation = transformation
      @id = id
    end

    attr_reader :path, :image_info, :transformation, :id

    def transform
      raise NotImplementedError, "Implement #transform in the concrete class"
    end
  end
end
