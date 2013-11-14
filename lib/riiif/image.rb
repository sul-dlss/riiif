require 'mini_magick'
module Riiif
  class Image
    class_attribute :file_resolver
    self.file_resolver = FileSystemFileResolver

    attr_reader :path_name

    # @param [String] id The identifier of the file
    def initialize(id)
      @path_name = file_resolver.find(id)
    end

    def render(args)
      options = validate_options!(args)
      image = load_image
      unless options[:size] == 'full'
        image.resize "100x100"
      end
      image.format(options[:format])
      image.to_blob
    end

    private

      def validate_options!(args)
        options = args.with_indifferent_access
        raise ArgumentError, 'You must provide a format' unless options[:format]
        options
      end

      def load_image
        begin
          image = MiniMagick::Image.open(path_name)
        rescue Errno::ENOENT => e
          Rails.logger.error "Unable to find #{path_name}"
          Rails.logger.error e.backtrace
          raise Riiif::Error, "Unable to find #{path_name}"
        rescue MiniMagick::Error => e
          Rails.logger.error "Error trying to open #{path_name}"
          Rails.logger.error e.backtrace
          raise Riiif::Error, "Unable to open the image #{path_name}"
        end
      end
  end
end
