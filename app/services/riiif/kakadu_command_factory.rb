# frozen_string_literal: true

module Riiif
  # Builds a command to run a transformation using Kakadu
  class KakaduCommandFactory
    class_attribute :external_command
    self.external_command = 'kdu_expand'

    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param [Transformation] transformation
    # @return [String] a command for running imagemagick to produce the requested output
    def self.build(path, transformation)
      new(path, transformation).build
    end

    # A helper method to instantiate and invoke build
    # @param [String] path the location of the file
    # @param [Transformation] transformation
    def initialize(path, transformation)
      @path = path
      @transformation = transformation
    end

    attr_reader :path, :transformation

    # @return [String] a command for running kdu_expand to produce the requested output
    def build
      # TODO: we must delete this link
      link_path = ::File.join(Dir.tmpdir, SecureRandom.uuid) + '.bmp'
      ::File.symlink('/dev/stdout', link_path)
      [external_command, quiet, input, threads, region, reduce, output(link_path)].join
    end

    private

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
        " -region #{region_arg}" if region_arg
      end

      def reduce
        " -reduce #{reduce_arg}" if reduce_arg
      end

      # TODO: finish
      def reduce_arg; end

      # TODO: finish
      # @return [String] e.g. '\{0.5,0.5\},\{0.5,0.5\}'
      def region_arg; end
  end
end
