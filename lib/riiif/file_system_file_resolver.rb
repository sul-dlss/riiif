module Riiif
  module FileSystemFileResolver
    mattr_accessor :root, :base_path, :input_types

    self.root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
    self.base_path = File.join(root, 'spec/samples')
    self.input_types = %W{png jpg tiff jp jp2}


    def self.find(id)
      Dir.glob(pattern(id)).first
    end

    def self.pattern(id)
      raise ArgumentException, "Invalid characters in id `#{id}`" unless /^[\w-]+$/.match(id)
      ::File.join(base_path, "#{id}.{#{input_types.join(',')}}")
    end

  end
end
