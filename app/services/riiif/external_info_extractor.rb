require "net/http"

module Riiif
  # Get information about an image from an external IIIF server
  class ExternalInfoExtractor
    attr_reader :path, :id

    def initialize(path:, id:)
      @path = path
      @id = id
    end

    def extract
      uri = URI("#{ENV['IIIF_BASE_URL']}/#{id}/info.json")

      JSON.parse(Net::HTTP.get_response(uri).body)
    end
  end
end
