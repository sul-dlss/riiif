module Riiif
  # Get height and width information using imagemagick to interrogate the file
  class ImageMagickInfoExtractor
    # perhaps you want to use GraphicsMagick instead, set to "gm identify"
    class_attribute :external_command
    self.external_command = 'identify'

    def initialize(path)
      @path = path
    end

    def extract
      height, width = Riiif::CommandRunner.execute("#{external_command} -format %hx%w #{@path}[0]").split('x')
      { height: Integer(height), width: Integer(width) }
    end
  end
end
