module Riiif
  # Transforms an image using a backend
  class AbstractTransformer
    # @param path [String] The path of the source image file
    # @param [Transformation] transformation
    def self.transform(path, transformation)
      new(path, transformation).transform
    end

    def initialize(path, transformation)
      @path = path
      @transformation = transformation
    end

    attr_reader :path, :transformation

    def transform
      command = command_factory.build(path, transformation)
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
