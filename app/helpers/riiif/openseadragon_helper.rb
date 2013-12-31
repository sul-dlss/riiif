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

      js =<<-EOF
        function initOpenSeadragon() {
          OpenSeadragon(#{JSON.pretty_generate(collection_options)});
        }
        window.onload = initOpenSeadragon;
        document.addEventListener("page:load", initOpenSeadragon); // Initialize when using turbolinks
      EOF
      #<%=javascript_include_tag "openseadragon.js" %>
      content_tag(:div, '', html_options) + javascript_tag(js) 
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
