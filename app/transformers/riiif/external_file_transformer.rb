module Riiif
  # Transforms an image from the filesystem using a backend
  class ExternalFileTransformer < AbstractTransformer
    def transform
      Net::HTTP.get_response(
        URI(
          "#{base_url}/" \
          "#{id}/" \
          "#{transformation.region}/" \
          "#{transformation.size}/" \
          "#{transformation.rotation}/" \
          "#{transformation.quality}.#{transformation.format}"
        )
      ).body
    end

    def base_url
      @base_url ||= ENV["IIIF_BASE_URL"]
    end
  end
end
