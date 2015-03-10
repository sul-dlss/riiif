require 'digest'
require 'cgi'
module Riiif
  class AkubraSystemFileResolver
    attr_accessor :pathroot, :imagetype, :akubraconfig

  def initialize(pr="/yourfedora/data/datastreamStore/",ir="jp2",ac=[[0,2],[2,2],[4,1]])
    @pathroot = pr
    @imagetype = ir
    @akubraconfig = ac
  end

    def find(id)
      Riiif::File.new(path(id))
    end

    def path(id)
      search = pattern(id)
      Dir.glob(search).first || raise(ImageNotFoundError, search)
    end

    def pattern(id)
      fullpid = "info:fedora/#{id}/#{@imagetype}/#{@imagetype}.0"
      md5 = Digest::MD5.new
      md5.update fullpid
      digest = md5.hexdigest
      directorystr = ""
      @akubraconfig.each { |a| directorystr << digest[a[0],a[1]] << "/" }
      filename = CGI.escape(fullpid)
      fullpath = @pathroot + directorystr + filename
      fullpath	  
    end
  end
end
