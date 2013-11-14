module Riiif
  class ImagesController < ::ApplicationController
    def show
      image = Image.new(params[:id])
      data = image.render(params.permit(:region, :size, :rotation, :quality, :format))
      # TODO need to send the type parameter?
      send_data data,:disposition => 'inline'
    end
  end
end
