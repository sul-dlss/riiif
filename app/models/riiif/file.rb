module Riiif
  class File
    attr_reader :path

    class_attribute :info_extractor_class
    self.info_extractor_class = ImageMagickInfoExtractor

    # @param input_path [String] The location of an image file
    def initialize(input_path, tempfile = nil)
      @path = input_path
      @tempfile = tempfile # ensures that the tempfile will stick around until this file is garbage collected.
    end

    def self.read(stream, ext)
      create(ext) do |f|
        while chunk = stream.read(8192)
          f.write(chunk)
        end
      end
    end

    def self.create(ext = nil, _validate = true, &block)

      tempfile = Tempfile.new(['mini_magick', ext.to_s.downcase])
      tempfile.binmode
      block.call(tempfile)
      tempfile.close
      image = new(tempfile.path, tempfile)
    ensure
      tempfile.close if tempfile

    end

    # @param [Transformation] transformation
    def extract(transformation)
      command = 'convert'
      command << " -crop #{transformation.crop}" if transformation.crop
      command << " -resize #{transformation.size}" if transformation.size
      if transformation.rotation
        command << " -virtual-pixel white +distort srt #{transformation.rotation}"
      end

      case transformation.quality
      when 'grey'
        command << ' -colorspace Gray'
      when 'bitonal'
        command << ' -colorspace Gray'
        command << ' -type Bilevel'
      end
      command << " #{path} #{transformation.format}:-"
      execute(command)
    end

    def info
      @info ||= info_extractor_class.new(path).extract
    end

    delegate :execute, to: Riiif::CommandRunner
    private :execute
  end
end
