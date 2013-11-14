require 'spec_helper'

describe 'routes for resizing' do
  routes { Riiif::Engine.routes }
  it "routes GET /abcd1234/full/full/0/native.jpg" do
    expect(
      get: "/abcd1234/full/full/0/native.jpg"
    ).to route_to(controller: "riiif/images", id: 'abcd1234', action: "show", 
                  region: 'full', size: 'full', rotation: '0', quality: 'native', format: 'jpg')
  end

end
