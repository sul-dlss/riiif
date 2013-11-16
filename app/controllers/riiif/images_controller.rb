module Riiif
  class ImagesController < ::ApplicationController
    before_filter :link_header, only: [:show, :info]
    def show
      image = Image.new(params[:id])
      data = image.render(params.permit(:region, :size, :rotation, :quality, :format))
      send_data data, type: Mime::Type.lookup_by_extension(params[:format]), :disposition => 'inline'
    end

    def info
      image = Image.new(params[:id])
      render json: image.info.merge(server_info)
    end

    def view
      @image = Image.new(params[:id])
    end

    protected

    def link_header
      response.headers["Link"] = '<http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2>;rel="profile"'
    end

    def server_info
      {
        "@context" => "http://library.stanford.edu/iiif/image-api/1.1/context.json",
        "@id" => request.original_url.sub('/info.json', ''), 
        "formats" => Image::OUTPUT_FORMATS,
        "profile" => "http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level0"
        
      }
    end
  end
end
