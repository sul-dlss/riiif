# frozen_string_literal: true

module Riiif
  # Builds a command to run a transformation using Kakadu
  class KakaduCommandFactory
    class_attribute :external_command
    self.external_command = 'kdu_expand'

    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param info [ImageInformation] information about the source
    # @param [Transformation] transformation
    # @return [String] a command for running imagemagick to produce the requested output
    def self.build(path, info, transformation)
      new(path, info, transformation).build
    end

    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param info [ImageInformation] information about the source
    # @param [Transformation] transformation
    def initialize(path, info, transformation)
      @path = path
      @info = info
      @transformation = transformation
    end

    attr_reader :path, :info, :transformation

    # @return [String] a command for running kdu_expand to produce the requested output
    def build
      # TODO: we must delete this link
      ::File.symlink('/dev/stdout', link_path)
      [external_command, quiet, input, threads, region, reduce, output(link_path)].join
    end

    private

      def link_path
        @link_path ||= LinkNameService.create
      end

      def input
        " -i #{path}"
      end

      def output(link_path)
        " -o #{link_path}"
      end

      def threads
        ' -num_threads 4'
      end

      def quiet
        ' -quiet'
      end

      def region
        region_arg = transformation.crop.to_kakadu
        " -region #{region_arg}" if region_arg
      end

      # kdu_expand is not capable of arbitrary scaling, but it does
      # offer a -reduce argument which is capable of downscaling by
      # factors of 2, significantly speeding decompression. We can
      # use it if either the percent is <=50, or the height/width
      # are <=50% of full size.
      def reduce
        " -reduce #{reduction_arg}" if reduction_arg
      end

      def reduction_arg
        reduced_size = transformation.crop
        transformation.size.reduction_factor(reduced_size)
      end
  end
end
