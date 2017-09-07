module Riiif
  class AbstractFileSystemResolver
    extend Deprecation
    attr_accessor :base_path

    def initialize(base_path: nil)
      @base_path = base_path || default_base_path
    end

    def default_base_path
      Deprecation.warn(self, 'Initializing a file resolver without setting the base path ' \
      'is deprecated and will be removed in Riiif 2.0', caller(2))
      @root ||= ::File.expand_path(::File.join(::File.dirname(__FILE__), '../..'))
      ::File.join(@root, 'spec/samples')
    end

    attr_reader :root
    deprecation_deprecate :root

    def find(id)
      Riiif::File.new(path(id))
    end

    # @param [String] id the id to resolve
    # @return the path of the file
    def path(id)
      search = pattern(id)
      Dir.glob(search).first || raise(ImageNotFoundError, search)
    end

    def pattern(_id)
      raise NotImplementedError, "Implement `pattern(id)' in the concrete class"
    end
  end
end
