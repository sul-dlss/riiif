require 'open3'
module Riiif
  class File
    include Open3
    include ActiveSupport::Benchmarkable

    attr_reader :path

    delegate :logger, to: :Rails

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
      return @info if @info
      height, width = execute("identify -format %hx%w #{path}").split('x')
      @info = { height: Integer(height), width: Integer(width) }
    end

    private

      def execute(command)
        out = nil
        benchmark("Riiif executed #{command}") do
          stdin, stdout, stderr, wait_thr = popen3(command)
          stdin.close
          stdout.binmode
          out = stdout.read
          stdout.close
          err = stderr.read
          stderr.close
          raise "Unable to execute command \"#{command}\"\n#{err}" unless wait_thr.value.success?
        end
        out
      end

  end
end
