module Riiif
  # Get information using imagemagick to interrogate the file
  class ImageMagickInfoExtractor
    # perhaps you want to use GraphicsMagick instead, set to "gm identify"
    class_attribute :external_command
    self.external_command = 'identify'

    def initialize(path)
      @path = path
    end

    def extract
      height, width, format, channels = Riiif::CommandRunner.execute(
        "#{external_command} -format '%h %w %m %[channels]' '#{@path}[0]'"
      ).split(' ')

      {
        height: Integer(height),
        width: Integer(width),
        format: format,
        channels: channels
      }
    end
  end
end
