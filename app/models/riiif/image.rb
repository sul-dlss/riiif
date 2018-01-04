require 'digest/md5'

##
# These explict requires are needed because in some contexts the Rails
# autoloader can either: unload already loaded classes, or cause a lock while
# trying to load a needed class.
require_dependency 'riiif/region/imagemagick/absolute_decoder'
require_dependency 'riiif/region/imagemagick/full_decoder'
require_dependency 'riiif/region/imagemagick/percentage_decoder'
require_dependency 'riiif/region/imagemagick/square_decoder'

require_dependency 'riiif/size/imagemagick/absolute_decoder'
require_dependency 'riiif/size/imagemagick/best_fit_decoder'
require_dependency 'riiif/size/imagemagick/full_decoder'
require_dependency 'riiif/size/imagemagick/height_decoder'
require_dependency 'riiif/size/imagemagick/percent_decoder'
require_dependency 'riiif/size/imagemagick/width_decoder'

module Riiif
  class Image
    extend Deprecation

    class_attribute :file_resolver, :info_service, :authorization_service, :cache
    self.file_resolver = FileSystemFileResolver.new(base_path: ::File.join(Rails.root, 'tmp'))
    self.authorization_service = NilAuthorizationService
    self.cache = Rails.cache

    # this is the default info service
    # returns a hash with the original image dimensions.
    # You can set your own lambda if you want different behavior
    # example:
    #   {:height=>390, :width=>600}
    self.info_service = lambda do |id, image|
      cache.fetch(cache_key(id, info: true), compress: true, expires_in: expires_in) do
        image.info
      end
    end

    attr_reader :id

    # @param [String] id The identifier of the file to be looked up.
    # @param [Riiif::File] file Optional: The Riiif::File to use instead of looking one up.
    def initialize(id, passed_file = nil)
      @id = id
      @file = passed_file if passed_file.present?
    end

    def file
      @file ||= file_resolver.find(id)
    end

    alias image file
    deprecation_deprecate image: 'Use Image#file instead. This will be removed in riiif 2.0'

    ##
    # @param [ActiveSupport::HashWithIndifferentAccess] args
    def render(args)
      cache_opts = args.select { |a| %w(region size quality rotation format).include? a.to_s }
      key = Image.cache_key(id, cache_opts)

      cache.fetch(key, compress: true, expires_in: Image.expires_in) do
        file.extract(OptionDecoder.decode(args, info))
      end
    end

    def info
      @info ||= begin
                  result = info_service.call(id, file)
                  ImageInformation.new(result[:width], result[:height])
                end
    end

    class << self
      def expires_in
        Riiif::Engine.config.cache_duration_in_days.days
      end

      def cache_key(id, options)
        str = options.to_h.merge(id: id)
                     .delete_if { |_, v| v.nil? }
                     .sort_by { |k, _v| k.to_s }
                     .to_s

        # Use a MD5 digest to ensure the keys aren't too long, and a prefix
        # to avoid collisions with other components in shared cache.
        'riiif:' + Digest::MD5.hexdigest(str)
      end
    end
  end
end
