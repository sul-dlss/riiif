module Riiif
  # Decodes the URL parameters into a Transformation object
  class OptionDecoder
    OUTPUT_FORMATS = %w(jpg png).freeze

    # a helper method for instantiating the OptionDecoder
    # @param [ActiveSupport::HashWithIndifferentAccess] options
    # @param [ImageInformation] image_info
    def self.decode(options, image_info)
      new(options, image_info).decode
    end

    # @param [ActiveSupport::HashWithIndifferentAccess] options
    # @param [ImageInformation] image_info
    def initialize(options, image_info)
      @options = options
      @image_info = image_info
    end

    attr_reader :image_info

    ##
    # @return [Transformation]
    def decode
      raise ArgumentError, "You must provide a format. You provided #{@options}" unless @options[:format]
      validate_format!(@options[:format])
      Riiif::Transformation.new(decode_region(@options.delete(:region)),
                                decode_size(@options.delete(:size)),
                                decode_quality(@options[:quality]),
                                decode_rotation(@options[:rotation]),
                                @options[:format])
    end

    def decode_quality(quality)
      return if quality.nil? || %w(default color).include?(quality)
      return quality if %w(bitonal grey).include?(quality)
      raise InvalidAttributeError, "Unsupported quality: #{quality}"
    end

    def decode_rotation(rotation)
      return if rotation.nil? || rotation == '0'
      begin
        Float(rotation)
      rescue ArgumentError
        raise InvalidAttributeError, "Unsupported rotation: #{rotation}"
      end
    end

    def validate_format!(format)
      raise InvalidAttributeError, "Unsupported format: #{format}" unless OUTPUT_FORMATS.include?(format)
    end

    # rubocop:disable Metrics/AbcSize
    def decode_region(region)
      if region.nil? || region == 'full'
        Riiif::Region::Full.new(image_info)
      elsif md = /^pct:(\d+(?:.\d+)?),(\d+(?:.\d+)?),(\d+(?:.\d+)?),(\d+(?:.\d+)?)$/.match(region)
        Riiif::Region::Percentage
          .new(image_info, md[1].to_f, md[2].to_f, md[3].to_f, md[4].to_f)
      elsif md = /^(\d+),(\d+),(\d+),(\d+)$/.match(region)
        Riiif::Region::Absolute.new(image_info, md[1].to_i, md[2].to_i, md[3].to_i, md[4].to_i)
      elsif region == 'square'
        Riiif::Region::Square.new(image_info)
      else
        raise InvalidAttributeError, "Invalid region: #{region}"
      end
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def decode_size(size)
      if size.nil? || size == 'full'
        Riiif::Size::Full.new
      elsif md = /^,(\d+)$/.match(size)
        Riiif::Size::Height.new(image_info, md[1].to_i)
      elsif md = /^(\d+),$/.match(size)
        Riiif::Size::Width.new(image_info, md[1].to_i)
      elsif md = /^pct:(\d+(?:.\d+)?)$/.match(size)
        Riiif::Size::Percent.new(image_info, md[1].to_f)
      elsif md = /^(\d+),(\d+)$/.match(size)
        Riiif::Size::Absolute.new(image_info, md[1].to_i, md[2].to_i)
      elsif md = /^!(\d+),(\d+)$/.match(size)
        Riiif::Size::BestFit.new(image_info, md[1].to_i, md[2].to_i)
      else
        raise InvalidAttributeError, "Invalid size: #{size}"
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/AbcSize
  end
end
