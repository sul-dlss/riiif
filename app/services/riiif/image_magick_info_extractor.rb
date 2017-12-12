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
      height, width, format = Riiif::CommandRunner.execute(
        "#{external_command} -format '%h %w %m' #{@path}[0]"
      ).split(' ')

      {
        height: Integer(height),
        width: Integer(width),
        format: format
      }
    end
  end
end
