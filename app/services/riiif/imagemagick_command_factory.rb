module Riiif
  # Builds a command to run a transformation using Imagemagick
  class ImagemagickCommandFactory
    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param [Transformation] transformation
    # @param [Integer] compression (85) the compression level to use (set 0 for no compression)
    # @return [String] a command for running imagemagick to produce the requested output
    def self.build(path, transformation, compression: 85)
      new(path, transformation, compression: compression).build
    end

    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param [Transformation] transformation
    # @param [Integer] compression the compression level to use (set 0 for no compression)
    def initialize(path, transformation, compression:)
      @path = path
      @transformation = transformation
      @compression = compression
    end

    attr_reader :path, :transformation, :compression

    # @return [String] a command for running imagemagick to produce the requested output
    def build
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
      command << " -quality #{compression}" if use_compression?
      command << " #{path} #{transformation.format}:-"
      command
    end

    private

      def use_compression?
        compression > 0 && transformation.format == 'jpg'
      end
  end
end
