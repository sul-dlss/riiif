module Riiif
  # Transforms an image using a backend
  class AbstractTransformer
    # @param path [String] The path of the source image file
    # @param info [ImageInformation] information about the source
    # @param [Transformation] transformation
    def self.transform(path, info, transformation)
      new(path, info, transformation).transform
    end

    def initialize(path, info, transformation)
      @path = path
      @info = info
      @transformation = transformation
    end

    attr_reader :path, :info, :transformation

    def transform
      command = command_factory.build(path, info, transformation)
      post_process(execute(command))
    end

    # override this method in subclasses if we need to transform the output data
    def post_process(image)
      image
    end

    delegate :execute, to: Riiif::CommandRunner
    private :execute
  end
end
