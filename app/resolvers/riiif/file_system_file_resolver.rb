module Riiif
  class FileSystemFileResolver < AbstractFileSystemResolver
    attr_writer :input_types

    # Returns a string suitable for a globbing match
    #   e.g. /base/path/67352ccc-d1b0-11e1-89ae-279075081939.{jp2,tiff,png}
    def pattern(id)
      validate_identifier!(id: id)
      ::File.join(base_path, "#{id}.{#{input_types.join(',')}}")
    end

    private

      def validate_identifier!(id:, regex: identifier_regex)
        raise ArgumentError, "Invalid characters in id `#{id}`" if id !~ regex
      end

      # Matches on word characters dashes and colons
      def identifier_regex
        /^[\w\-:]+$/
      end

      def input_types
        @input_types ||= %w(png jpg tif tiff jp2)
      end
  end
end
