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
      image.resize options[:size] unless options[:size] == 'full'
      image.format(options[:format])
      image.to_blob
    end

    private

      def validate_options!(args)
        options = args.with_indifferent_access
        raise ArgumentError, 'You must provide a format' unless options[:format]
        options[:size] = validate_size(options.delete(:size))
        options
      end

      def validate_size(size)
        if size == 'full'
          size
        elsif md = /^,(\d+)$/.match(size)
          "x#{md[1]}"
        elsif md = /^(\d+),$/.match(size)
          "#{md[1]}"
        elsif md = /^pct:(\d+)$/.match(size)
          "#{md[1]}%"
        elsif md = /^(\d+),(\d+)$/.match(size)
          "#{md[1]}x#{md[2]}!"
        elsif md = /^!(\d+),(\d+)$/.match(size)
          "#{md[1]}x#{md[2]}"
        else
          raise InvalidAttributeError, "Invalid size: #{size}"
        end

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
