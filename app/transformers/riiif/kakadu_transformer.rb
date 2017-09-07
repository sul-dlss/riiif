module Riiif
  # Transforms an image using Kakadu
  class KakaduTransformer < AbstractTransformer
    def command_factory
      KakaduCommandFactory
    end

    # The data we get back from kdu_expand is a bmp and we need to change it
    # to the requested format by calling Imagemagick.
    # TODO: Calculate a new set of transforms with respect to reduction_factor
    def post_process(data, reduction_factor)
      puts "Reduction factor is #{reduction_factor}"
      data_io = StringIO.new(data)
      data_io.binmode
      out = ''
      command = "/usr/local/bin/convert - #{transformation.format}:-"
      IO.popen(command, 'r+b') do |io|
        io.write(data_io.read(4096)) until data_io.eof?
        io.close_write
        # Read from convert into our buffer
        out << io.read(4096) until io.eof?
      end
      out
    end
  end
end
