Riiif::Engine.routes.draw do
  ALLOW_DOTS ||= /[\w.]+/
  get "/:id/:region/:size/:rotation/:quality(.:format)" => "images#show", :constraints => { :rotation => ALLOW_DOTS}
  get "/:id/info(.:format)" => "images#info", :constraints => { :format => /json/}
end
