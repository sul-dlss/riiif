module Riiif
  module HTTPFileResolver

    # Set a lambda that maps the first parameter (id) to a URL
    # Example:
    #
    # Riiif::HTTPFileResolver.id_to_uri = lambda do |id| 
    #  "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
    # end
    #
    mattr_accessor :id_to_uri

    def self.find(id)
      uri(id)
    end

    protected

    def self.uri(id)
      raise "Must set the id_to_uri lambda" if id_to_uri.nil?
      id_to_uri.call(id)
    end
  end
end
