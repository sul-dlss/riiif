require 'spec_helper'

describe Riiif::ImagesController do
  routes { Riiif::Engine.routes }
  it "should send images to the service" do
    image = double
    expect(Riiif::Image).to receive(:new).with('abcd1234').and_return(image)
    expect(image).to receive(:render).with("region" => 'full', "size" => 'full',
                              "rotation" => '0', "quality" => 'native',
                              "format" => 'jpg').and_return("IMAGEDATA")
    get :show, id: 'abcd1234', action: "show", region: 'full', size: 'full', 
               rotation: '0', quality: 'native', format: 'jpg'
    expect(response).to be_successful
    expect(response.body).to eq 'IMAGEDATA'
  end
end
