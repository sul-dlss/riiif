module Riiif
  # Transforms an image using Imagemagick
  class ImagemagickTransformer < AbstractFsTransformer
    def command_factory
      ImagemagickCommandFactory
    end
  end
end
