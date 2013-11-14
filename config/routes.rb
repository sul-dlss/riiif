Riiif::Engine.routes.draw do
  get "/:id/:region/:size/:aspect/native(.:format)" => "images#show"
end
