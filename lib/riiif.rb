require 'riiif/version'
require 'deprecation'
require 'riiif/engine'
module Riiif
  extend ActiveSupport::Autoload
  autoload :Image
  autoload :AbstractFileSystemResolver
  autoload :FileSystemFileResolver
  autoload :HTTPFileResolver
  autoload :Routes
  autoload :AkubraSystemFileResolver
  autoload :NilAuthorizationService

  class Error < RuntimeError; end
  class InvalidAttributeError < Error; end
  class ImageNotFoundError < Error; end

  # This error is raised when Riiif can't convert an image
  class ConversionError < Error; end

  Transformation = Struct.new(:crop, :size, :quality, :rotation, :format)
  mattr_accessor :not_found_image # the image to use when a lookup fails
  mattr_accessor :unauthorized_image # the image to use when a user doesn't have access
end
