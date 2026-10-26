require "ruby-vips" if Riiif::Engine.config.use_vips

module Riiif
  # Get information using (lib)vips to interrogate the file
  class VipsInfoExtractor < AbstractInfoExtractor
    self.external_command = "vipsheader"

    def extract
      vipsloader = Riiif::CommandRunner.execute(
        "#{external_command} -f vips-loader '#{@path}'"
      ).strip
      image = ::Vips::Image.new_from_file(@path.to_s)
      image = image.autorot if Riiif.autorotate?

      {
        height: image.height,
        width: image.width,
        format: vipsloader.match?("pngload") ? "PNG" : "JPEG",
        channels: image.has_alpha? ? "srgba" : "srgb"
      }
    end
  end
end
