require 'spec_helper'

describe "routes" do
  routes { Riiif::Engine.routes }

  describe 'for conversion' do
    it "routes GET /abcd1234/full/full/0/native.jpg" do
      expect(
        get: "/abcd1234/full/full/0/native.jpg"
      ).to route_to(controller: "riiif/images", id: 'abcd1234', action: "show", 
                    region: 'full', size: 'full', rotation: '0', 
                    quality: 'native', format: 'jpg')
    end

    it "routes requests with floating point percent size" do
      expect(
        get: "/abcd1234/full/pct:12.5/22.5/native.jpg"
      ).to route_to(controller: "riiif/images", id: 'abcd1234', action: "show", 
                    region: 'full', size: 'pct:12.5', rotation: '22.5', 
                    quality: 'native', format: 'jpg')
    end
    it "routes requests with pixel size" do
      expect(
        get: "/abcd1234/full/100,50/22.5/native.jpg"
      ).to route_to(controller: "riiif/images", id: 'abcd1234', action: "show", 
                    region: 'full', size: '100,50', rotation: '22.5', 
                    quality: 'native', format: 'jpg')
    end
  end

  describe "for info" do
    it "routes GET /abcd1234/info.json" do
      expect(
        get: "/abcd1234/info.json"
      ).to route_to(controller: "riiif/images", id: 'abcd1234', 
                    action: "info", format: 'json')
    end
  end
end
