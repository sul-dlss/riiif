module Riiif
  class ExternalFile < ::Riiif::File
    attr_reader :path, :id

    # @param path [String] The location of an image file
    # @param id [String] the ID of the image
    def initialize(path:, id:)
      @path = path
      @id = id
    end

    def transformer
      ExternalFileTransformer
    end

    def info_extractor
      @info_extractor ||= ExternalInfoExtractor.new(path: path, id: id)
    end
  end
end
