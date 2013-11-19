module Riiif
  module FileSystemFileResolver
    mattr_accessor :root, :base_path, :input_types

    self.root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
    self.base_path = File.join(root, 'spec/samples')
    self.input_types = %W{png jpg tiff jp jp2}


    def self.find(id)
      Riiif::File.new(path(id))
    end

    def self.path(id)
      search = pattern(id)
      Dir.glob(search).first || raise(Errno::ENOENT, search)
    end


    def self.pattern(id)
      raise ArgumentError, "Invalid characters in id `#{id}`" unless /^[\w\-:]+$/.match(id)
      ::File.join(base_path, "#{id}.{#{input_types.join(',')}}")
    end

  end
end
