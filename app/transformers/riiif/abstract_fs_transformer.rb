module Riiif
  # Transforms an image from the filesystem using a backend
  class AbstractFsTransformer < AbstractTransformer
    def transform
      execute(command_builder.command)
    end

    def command_builder
      @command_builder ||= command_factory.new(path, image_info, transformation)
    end

    delegate :execute, to: Riiif::CommandRunner
    private :execute
  end
end
