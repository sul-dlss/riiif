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
    expect(response.headers['Link']).to eq '<http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2>;rel="profile"'
  end

  it "should return info" do
    image = double
    expect(Riiif::Image).to receive(:new).with('abcd1234').and_return(image)
    expect(image).to receive(:info).and_return({width: 6000, height: 4000 })
    get :info, id: 'abcd1234', format: 'json'
    expect(response).to be_successful
    json = JSON.parse(response.body)
    expect(json).to eq "@context"=>"http://library.stanford.edu/iiif/image-api/1.1/context.json",
      "@id" =>"http://test.host/image-service/abcd1234",
      "width" =>6000,
      "height" =>4000,
      "formats" =>  [ "jpg", "png" ],
      "profile" =>  "http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level0" 
    expect(response.headers['Link']).to eq '<http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2>;rel="profile"'
  end
end
