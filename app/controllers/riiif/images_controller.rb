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
      headers['Access-Control-Allow-Origin'] = '*'
      send_data data,
                status: status,
                type: Mime::Type.lookup_by_extension(params[:format]),
                disposition: 'inline'
    end

    def info
      image = model.new(image_id)
      headers['Access-Control-Allow-Origin'] = '*'
      render json: image.info.merge(server_info), content_type: 'application/ld+json'
    end

    # this is a workaround for https://github.com/rails/rails/issues/25087
    def redirect
      redirect_to info_path(params[:id])
    end

    protected

    LEVEL1 = 'http://iiif.io/api/image/2/level1.json'

    def model
      params.fetch(:model, "riiif/image").camelize.constantize
    end

    def image_id
      params[:id]
    end

    def link_header
      response.headers["Link"] = "<#{LEVEL1}>;rel=\"profile\""
    end

    CONTEXT = '@context'
    CONTEXT_URI = 'http://iiif.io/api/image/2/context.json'
    ID = '@id'
    PROTOCOL = 'protocol'
    PROTOCOL_URI = 'http://iiif.io/api/image'
    PROFILE = 'profile'

    def server_info
      {
        CONTEXT => CONTEXT_URI,
        ID => request.original_url.sub('/info.json', ''),
        PROTOCOL => PROTOCOL_URI,
        PROFILE => [LEVEL1, 'formats' => model::OUTPUT_FORMATS]
      }
    end
  end
end
