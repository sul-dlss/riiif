Riiif::Engine.routes.draw do
  ALLOW_DOTS ||= /[\w.]+/
  PERCENTAGE ||= /(pct:)?[\w.]+/
  get "/:id/:region/:size/:rotation/:quality(.:format)" => "images#show", 
    constraints: { rotation: ALLOW_DOTS, size: PERCENTAGE}
  get "/:id/info(.:format)" => "images#info", :constraints => { :format => /json/}
  get "/:id/view(.:format)" => "images#view"
end
