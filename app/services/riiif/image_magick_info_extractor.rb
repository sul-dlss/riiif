module Riiif
  # Get height and width information using imagemagick to interrogate the file
  class ImageMagickInfoExtractor
    def initialize(path)
      @path = path
    end

    def extract
      height, width = Riiif::CommandRunner.execute("identify -format %hx%w #{@path}[0]").split('x')
      { height: Integer(height), width: Integer(width) }
    end
  end
end
