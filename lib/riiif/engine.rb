module Riiif
  class Engine < ::Rails::Engine
    require 'riiif/rails/routes'

    # How long to cache the tiles for.
    config.cache_duration_in_days = 3

    config.action_dispatch.rescue_responses.merge!(
      'Riiif::ImageNotFoundError' => :not_found
    )
  end
end
