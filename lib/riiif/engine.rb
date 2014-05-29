module Riiif
  class Engine < ::Rails::Engine
    isolate_namespace Riiif

    # How long to cache the tiles for.
    config.cache_duration_in_days = 3
  end
end
