module Riiif
  class AbstractFileSystemResolver
    attr_accessor :root, :base_path

    def initialize
      @root = ::File.expand_path(::File.join(::File.dirname(__FILE__), '../..'))
      @base_path = ::File.join(root, 'spec/samples')
    end

    def find(id)
      Riiif::File.new(path(id))
    end

    # @param [String] id the id to resolve
    # @return the path of the file
    def path(id)
      search = pattern(id)
      Dir.glob(search).first || raise(ImageNotFoundError, search)
    end

    def pattern(id)
      raise NotImplementedError, "Implement `pattern(id)' in the concrete class"
    end
  end
end

