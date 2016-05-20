require 'spec_helper'

describe "for the base route", type: :request do
  it "routes GET /abcd1234" do
    get "/image-service/abcd1234"
    expect(response).to redirect_to ('/image-service/abcd1234/info.json')
  end
end
