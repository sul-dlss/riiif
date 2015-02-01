require 'spec_helper'
require 'open-uri'

describe Riiif::ImagesController do
  let(:filename) { File.expand_path('spec/samples/world.jp2') }
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
      "@id" =>"http://test.host/abcd1234",
      "width" =>6000,
      "height" =>4000,
      "formats" =>  [ "jpg", "png" ],
      "profile" =>  "http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2" 
    expect(response.headers['Link']).to eq '<http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2>;rel="profile"'
  end

  context "with a nonexistent image" do
    it "should error when a default image isn't sent" do
      expect(Riiif::Image).to receive(:new).with('bad_id').and_raise(OpenURI::HTTPError.new("fail", StringIO.new))
      expect do
        get :show, id: 'bad_id', action: "show", region: 'full', size: 'full',
                   rotation: '0', quality: 'native', format: 'jpg'
      end.to raise_error(StandardError)
    end

    context "with a default image set" do
      around do |example|
        old_value = Riiif.not_found_image
        Riiif.not_found_image = filename
        example.run
        Riiif.not_found_image = old_value
      end

      it "should send the default 'not found' image for failed http files" do
        not_found_image = double
        expect(Riiif::Image).to receive(:new) do |id, file|
          if file.present?
            not_found_image
          else
            raise Riiif::ImageNotFoundError
          end
        end.twice
        expect(not_found_image).to receive(:render).with("region" => 'full', "size" => 'full',
                                  "rotation" => '0', "quality" => 'native',
                                  "format" => 'jpg').and_return("default-image-data")

        get :show, id: 'bad_id', action: "show", region: 'full', size: 'full',
                   rotation: '0', quality: 'native', format: 'jpg'
        expect(response).to be_not_found
        expect(response.body).to eq 'default-image-data'
      end

      it "should send the default 'not found' image for failed files on the filesystem" do
        not_found_image = double
        expect(Riiif::Image).to receive(:new) do |id, file|
          if file.present?
            not_found_image
          else
            raise Riiif::ImageNotFoundError
          end
        end.twice
        expect(not_found_image).to receive(:render).with("region" => 'full', "size" => 'full',
                                  "rotation" => '0', "quality" => 'native',
                                  "format" => 'jpg').and_return("default-image-data")

        get :show, id: 'bad_id', action: "show", region: 'full', size: 'full', 
                   rotation: '0', quality: 'native', format: 'jpg'
        expect(response).to be_not_found
        expect(response.body).to eq 'default-image-data'
      end
    end
  end
end
