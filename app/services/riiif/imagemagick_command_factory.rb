# frozen_string_literal: true

module Riiif
  # Builds a command to run a transformation using Imagemagick
  class ImagemagickCommandFactory
    # perhaps you want to use GraphicsMagick instead, set to "gm convert"
    class_attribute :external_command
    self.external_command = 'convert'

    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param info [ImageInformation] information about the source
    # @param [Transformation] transformation
    # @param [Integer] compression (85) the compression level to use (set 0 for no compression)
    # @param [String] sampling_factor ("4:2:0") the chroma sample factor (set 0 for no compression)
    # @param [Boolean] strip_metadata (true) do we want to strip EXIF tags?
    # @return [String] a command for running imagemagick to produce the requested output
    def self.build(path, info, transformation, compression: 85, sampling_factor: '4:2:0', strip_metadata: true)
      new(path, info, transformation,
          compression: compression,
          sampling_factor: sampling_factor,
          strip_metadata: strip_metadata).build
    end

    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param info [ImageInformation] information about the source
    # @param [Transformation] transformation
    # @param [Integer] compression the compression level to use (set 0 for no compression)
    def initialize(path, info, transformation, compression:, sampling_factor:, strip_metadata:)
      @path = path
      @info = info
      @transformation = transformation
      @compression = compression
      @sampling_factor = sampling_factor
      @strip_metadata = strip_metadata
    end

    attr_reader :path, :info, :transformation, :compression, :sampling_factor, :strip_metadata

    # @return [String] a command for running imagemagick to produce the requested output
    def build
      [external_command, crop, size, rotation, colorspace, quality, sampling, metadata, input, output].join
    end

    private

      def use_compression?
        compression > 0 && jpeg?
      end

      def jpeg?
        transformation.format == 'jpg'.freeze
      end

      def input
        " #{path}"
      end

      # pipe the output to STDOUT
      def output
        " #{transformation.format}:-"
      end

      def crop
        directive = transformation.crop.to_imagemagick
        " -crop #{directive}" if directive
      end

      def size
        directive = transformation.size.to_imagemagick
        " -resize #{directive}" if directive
      end

      def rotation
        " -virtual-pixel white +distort srt #{transformation.rotation}" if transformation.rotation
      end

      def quality
        " -quality #{compression}" if use_compression?
      end

      def metadata
        ' -strip' if strip_metadata
      end

      def sampling
        " -sampling-factor #{sampling_factor}" if jpeg?
      end

      def colorspace
        case transformation.quality
        when 'grey'
          ' -colorspace Gray'
        when 'bitonal'
          ' -colorspace Gray -type Bilevel'
        end
      end
  end
end
