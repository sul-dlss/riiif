module Riiif
  class ImagesController < ::ApplicationController
    before_filter :link_header, only: [:show, :info]

    rescue_from Riiif::InvalidAttributeError do
      render nothing: true, status: 400
    end

    def show
      begin
        image = model.new(image_id)
        status = :ok
      rescue ImageNotFoundError
        if Riiif.not_found_image.present?
          image = model.new(image_id, Riiif::File.new(Riiif.not_found_image))
          status = :not_found
        else
          raise
        end
      end
      data = image.render(params.permit(:region, :size, :rotation, :quality, :format))
      send_data data, status: status, type: Mime::Type.lookup_by_extension(params[:format]), :disposition => 'inline'
    end

    def info
      image = model.new(image_id)
      render json: image.info.merge(server_info), content_type: 'application/ld+json'
    end

    protected

    LEVEL2 = 'http://library.stanford.edu/iiif/image-api/1.1/compliance.html#level2'
    def model
      params.fetch(:model, "riiif/image").camelize.constantize
    end

    def image_id
      params[:id]
    end

    def link_header
      response.headers["Link"] = "<#{LEVEL2}>;rel=\"profile\""
    end

    def server_info
      {
        "@context" => "http://library.stanford.edu/iiif/image-api/1.1/context.json",
        "@id" => request.original_url.sub('/info.json', ''), 
        "formats" => model::OUTPUT_FORMATS,
        "profile" => "#{LEVEL2}"
        
      }
    end
  end
end
