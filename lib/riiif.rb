require "riiif/version"
require "riiif/engine"

module Riiif
  extend ActiveSupport::Autoload
  autoload :Image
  autoload :FileSystemFileResolver
  autoload :HTTPFileResolver

  class Error < RuntimeError; end
  class InvalidAttributeError < Error; end
end
