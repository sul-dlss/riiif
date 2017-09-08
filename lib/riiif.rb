require 'riiif/version'
require 'deprecation'
require 'riiif/engine'
module Riiif
  extend ActiveSupport::Autoload
  autoload :Routes

  class Error < RuntimeError; end
  class InvalidAttributeError < Error; end
  class ImageNotFoundError < Error; end

  # This error is raised when Riiif can't convert an image
  class ConversionError < Error; end

  mattr_accessor :not_found_image # the image to use when a lookup fails
  mattr_accessor :unauthorized_image # the image to use when a user doesn't have access

  def self.kakadu_enabled?
    Engine.config.kakadu_enabled
  end
end
