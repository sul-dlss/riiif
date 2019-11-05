Riiif::Engine.routes.draw do
  iiif_for 'riiif/image', **Riiif::Engine.config.iiif_routes
end
