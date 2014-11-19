require 'digest'
require 'cgi'
module Riiif
  module AkubraSystemFileResolver
    mattr_accessor :pathroot, :imagetype, :akubraconfig
    self.pathroot = "/yourfedora/data/datastreamStore/"
    self.imagetype = "jp2"
    self.akubraconfig = [[0,2],[2,2],[4,1]]

    def self.find(id)
      Riiif::File.new(path(id))
    end

    def self.path(id)
      search = pattern(id)
      Dir.glob(search).first || raise(ImageNotFoundError, search)
    end

    def self.pattern(id)
      fullpid = "info:fedora/#{id}/#{imagetype}/#{imagetype}.0"
      md5 = Digest::MD5.new
      md5.update fullpid
      digest = md5.hexdigest
      directorystr = ""
      akubraconfig.each { |a| directorystr << digest[a[0],a[1]] << "/" }
      filename = CGI.escape(fullpid)
      fullpath = pathroot + directorystr + filename
      fullpath	  
    end
  end
end
