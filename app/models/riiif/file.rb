module Riiif
  class File
    attr_reader :path

    class_attribute :info_extractor_class
    # TODO: add alternative that uses kdu_jp2info
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
    deprecation_deprecate read: 'Riiif::File.read is deprecated and will be removed in version 2.0'

    # Yields a tempfile to the provided block
    # @return [Riiif::File] a file backed by the Tempfile
    def self.create(ext = nil, _validate = true, &block)
      tempfile = Tempfile.new(['mini_magick', ext.to_s.downcase])
      tempfile.binmode
      block.call(tempfile)
      tempfile.close
      image = new(tempfile.path, tempfile)
    ensure
      tempfile.close if tempfile
    end
    deprecation_deprecate create: 'Riiif::File.create is deprecated and will be removed in version 2.0'

    # @param [Transformation] transformation
    # @param [ImageInformation] image_info
    # @return [String] the processed image data
    def extract(transformation, image_info = info)
      transformer.transform(path, image_info, transformation)
    end

    def transformer
      if Riiif.kakadu_enabled? && path.ends_with?('.jp2')
        KakaduTransformer
      else
        ImagemagickTransformer
      end
    end

    def info
      @info ||= info_extractor.extract
    end

    def info_extractor
      @info_extractor ||= info_extractor_class.new(path)
    end
  end
end
