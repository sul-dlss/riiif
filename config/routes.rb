Riiif::Engine.routes.draw do
  get "/:id/:region/:size/:rotation/:quality(.:format)" => "images#show"
end
