module Riiif
  class ImagesController < ::ApplicationController
    def show
      image = Image.new(params[:id])
      data = image.render(params.permit(:region, :size, :rotation, :quality, :format))
      send_data data, type: Mime::Type.lookup_by_extension(params[:format]), :disposition => 'inline'
    end
  end
end
