require "ruby-vips" if Riiif::Engine.config.use_vips

module Riiif
  # Get information using (lib)vips to interrogate the file
  class VipsInfoExtractor < AbstractInfoExtractor
    self.external_command = "vipsheader"

    def extract
      width, height, vipsloader = Riiif::CommandRunner.execute(
        "#{external_command} -f width -f height -f vips-loader '#{@path}'"
      ).split("\n")

      {
        height: Integer(height),
        width: Integer(width),
        format: vipsloader.match?("pngload") ? "PNG" : "JPEG",
        channels: ::Vips::Image.new_from_file(@path.to_s).has_alpha? ? "srgba" : "srgb"
      }
    end
  end
end
