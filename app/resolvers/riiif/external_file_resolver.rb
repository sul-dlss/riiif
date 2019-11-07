module Riiif
  class ExternalFileResolver
    def initialize; end

    def find(id)
      Riiif::ExternalFile.new(path: nil, id: id)
    end
  end
end
