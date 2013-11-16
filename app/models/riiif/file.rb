require 'open3'
module Riiif
  class File
    include Open3
    attr_reader :path
    # @param input_path [String] The location of an image file
    def initialize(input_path, tempfile = nil)
      raise "HUH" if input_path.is_a? Riiif::File
      @path = input_path
      @tempfile = tempfile # ensures that the tempfile will stick around until this file is garbage collected.
    end

    def self.open(file_or_url, ext = nil)
      file_or_url = file_or_url.to_s # Force it to be a String... hell or highwater
      if file_or_url.include?("://")
        require 'open-uri'
        ext ||= ::File.extname(URI.parse(file_or_url).path)
        Kernel::open(file_or_url) do |f|
          self.read(f, ext)
        end
      else
        self.new(file_or_url)
      end
    end

    def self.read(stream, ext)
      create(ext) do |f|
        while chunk = stream.read(8192)
          f.write(chunk)
        end
      end
    end

    def self.create(ext = nil, validate = true, &block)
      begin
        tempfile = Tempfile.new(['mini_magick', ext.to_s.downcase])
        tempfile.binmode
        block.call(tempfile)
        tempfile.close
        image = self.new(tempfile.path, tempfile)
      ensure
        tempfile.close if tempfile
      end
    end

    def extract(options)

      command = 'convert'
      command << " -crop #{options[:crop]}" if options[:crop]
      command << " -resize #{options[:size]}" if options[:size]
      if options[:rotation]
        command << " -virtual-pixel white +distort srt #{options[:rotation]}"
      end

      case options[:quality]
      when 'grey'
        command << ' -colorspace Gray'
      when 'bitonal'
        command << ' -colorspace Gray'
        command << ' -type Bilevel'
      end
      command << " #{path} #{options[:format]}:-"
      Rails.logger.debug "RIIIF executed: #{command}"
      execute(command)
    end

    def info
      return @info if @info
      height, width = execute("identify -format %hx%w #{path}").split('x')
      @info = {height: Integer(height), width: Integer(width)}
    end

    private
      def execute(command)
          stdin, stdout, stderr, wait_thr = popen3(command)
          stdin.close
          stdout.binmode
          out = stdout.read
          stdout.close
          err = stderr.read
          stderr.close
          raise "Unable to execute command \"#{command}\"\n#{err}" unless wait_thr.value.success?
          out
      end

  end
end
