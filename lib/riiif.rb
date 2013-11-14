require "riiif/version"
require "riiif/engine"

module Riiif
  extend ActiveSupport::Autoload
  autoload :Image
  autoload :FileSystemFileResolver

  class Error < RuntimeError; end
end
