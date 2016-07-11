require 'riiif/version'
require 'riiif/engine'

module Riiif
  extend ActiveSupport::Autoload
  autoload :Image
  autoload :FileSystemFileResolver
  autoload :HTTPFileResolver
  autoload :Routes
  autoload :AkubraSystemFileResolver
  autoload :NilAuthorizationService

  class Error < RuntimeError; end
  class InvalidAttributeError < Error; end
  class ImageNotFoundError < Error
    attr_reader :original_exception
    def initialize(orig = nil)
      @original_exception = orig
    end
  end

  mattr_accessor :not_found_image # the image to use when a lookup fails
end
