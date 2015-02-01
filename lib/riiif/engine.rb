module Riiif
  class Engine < ::Rails::Engine
    require 'riiif/rails/routes'

    # How long to cache the tiles for.
    config.cache_duration_in_days = 3
  end
end
