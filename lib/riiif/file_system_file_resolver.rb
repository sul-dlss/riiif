module Riiif
  class FileSystemFileResolver < AbstractFileSystemResolver
    attr_writer :input_types

    def pattern(id)
      raise ArgumentError, "Invalid characters in id `#{id}`" unless id =~ /^[\w\-:]+$/
      ::File.join(base_path, "#{id}.{#{input_types.join(',')}}")
    end

    private

      def input_types
        @input_types ||= %w(png jpg tif tiff jp2)
      end
  end
end
