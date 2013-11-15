module Riiif
  module HTTPFileResolver

    # Set a lambda that maps the first parameter (id) to a URL
    # Example:
    #
    # Riiif::HTTPFileResolver.id_to_path = lambda do |id| 
    #  "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
    # end
    #
    mattr_accessor :id_to_path

    def self.find(id)
      raise "Must set the id_to_path lambda" if id_to_path.nil?
      id_to_path.call(id)
    end
  end
end
