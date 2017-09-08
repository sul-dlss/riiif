module Riiif
  class Engine < ::Rails::Engine
    require 'riiif/rails/routes'

    # How long to cache the tiles for.
    config.cache_duration_in_days = 3

    config.action_dispatch.rescue_responses['Riiif::ImageNotFoundError'] = :not_found

    # Set to true to use kdu for jp2000 source images
    config.kakadu_enabled = false
  end
end
