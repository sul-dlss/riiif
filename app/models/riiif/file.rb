module Riiif
  class File
    attr_reader :path, :id

    class_attribute :info_extractor_class
    # TODO: add alternative that uses kdu_jp2info
    self.info_extractor_class = ImageMagickInfoExtractor

    # @param path [String] The location of an image file
    # @param id [String] the ID of the image
    def initialize(path: nil, id: nil)
      @path = path
      @id = id
    end

    # @param [IIIF::Image::Transformation] transformation
    # @param [ImageInformation] image_info
    # @return [String] the processed image data
    def extract(transformation:, image_info: nil)
      transformer.transform(path: path,
                            image_info: image_info,
                            transformation: transformation,
                            id: id)
    end

    def transformer
      if Riiif.kakadu_enabled? && path.ends_with?('.jp2')
        KakaduTransformer
      else
        ImagemagickTransformer
      end
    end

    # @return [Hash]
    def info
      @info ||= info_extractor.extract
    end

    def info_extractor
      @info_extractor ||= info_extractor_class.new(path: path, id: id)
    end
  end
end
