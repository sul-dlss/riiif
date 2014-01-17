module Riiif
  module OpenseadragonHelper

    def openseadragon_collection_viewer(ids_or_images, options={})
      html_options = (options[:html] or {})
      html_options[:id] = (options[:id] or :openseadragon1)

      tile_sources = ids_or_images.zip((options[:tileSources] or [])).map do |id_or_image, opts|
        image_options(id_or_image, opts)
      end

      collection_options = {
        id: html_options[:id],
        prefixUrl: '/assets/openseadragon/',
        tileSources: tile_sources,
      }.deep_merge(options.except(:html, :tileSources))

      js_options = options_to_js(collection_options.except(:options_with_raw_js),
                                 collection_options[:options_with_raw_js])

      js =<<-EOF
        function initOpenSeadragon() {
          OpenSeadragon(#{js_options});
        }
        window.onload = initOpenSeadragon;
        document.addEventListener("page:load", initOpenSeadragon); // Initialize when using turbolinks
      EOF
      content_tag(:div, '', html_options) + javascript_tag(js) 
    end

    # converts a ruby hash to a javascript object without stringifying the raw_js_keys
    # so you can put js variables in there
    def options_to_js(options, raw_js_keys=[])
      normal = options.except(*raw_js_keys).map do |k, v|
        val = if v.is_a?(Hash) or v.is_a?(Array)
                JSON.pretty_generate(v)
              else
                JSON.dump(v)
              end
        JSON.dump(k) + ": " + val
      end
      raw_js = options.slice(*raw_js_keys).map{|k, v| k.to_s + ": " + v.to_s}
      "{\n" + (normal + raw_js).join(",\n") + "}"
    end

    def openseadragon_viewer(id_or_image, options={})
      opts = {}
      opts[:id] = options[:html_id] if options[:html_id]
      opts[:prefixUrl] = options[:prefix_url] if options[:prefix_url]
      opts[:tileSources] = [options.slice(:image_host, :tile_width, :tile_height)]
      opts.deep_merge!(options.except(:html_id, :prefix_url, :image_host, :tile_width, :tile_height))
      openseadragon_collection_viewer([id_or_image], opts)
    end

    private

    def image_options(id_or_image, options)
      options ||= {}
      image = case id_or_image
        when String
          Image.new(id_or_image)
        when Image
          id_or_image
        end
      {
        identifier: image.id,
        width: image.info[:width],
        height: image.info[:height],
        scale_factors: [1, 2, 3, 4, 5],
        formats: [:jpg, :png],
        qualities: [:native, :bitonal, :grey, :color],
        profile: "http://library.stanford.edu/iiif/image-api/compliance.html#level3",
        tile_width: 1024,
        tile_height: 1024,
        image_host: '/image-service',
      }.merge(options)
    end
  end
end
