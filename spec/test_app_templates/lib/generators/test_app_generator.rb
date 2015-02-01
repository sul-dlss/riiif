require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "spec/test_app_templates"

  def add_routes
    route "iiif_for 'riiif/image', at: '/image-service'"
  end

end
