module Riiif
  module OpenseadragonHelper
    def openseadragon_viewer(id_or_image, options={})
      image = case id_or_image
      when String
        Image.new(id_or_image)
      when Image
        id_or_image
      end
      options[:tile_width] ||= '1024'
      options[:tile_height] ||= '1024'
      options[:html_id] ||= 'openseadragon1'
      options[:html] ||= {}
      options[:html][:id] = options[:html_id]
      options[:image_host] ||= '/image-service'
      options[:prefix_url] ||= '/assets/openseadragon/'
      js =<<-EOF
        function initOpenSeadragon() {
          OpenSeadragon({
            id: "#{options[:html_id]}",
            prefixUrl: "#{options[:prefix_url]}",
            tileSources:   [{
            "image_host":     "#{options[:image_host]}",
            "identifier":   "#{image.id}",   
            "width":        #{image.info[:width]},   
            "height":       #{image.info[:height]},   
            "scale_factors": [1, 2, 3, 4, 5],   
            "tile_width":   #{options[:tile_width]},   
            "tile_height":  #{options[:tile_height]},   
            "formats":      [ "jpg", "png" ],   
            "qualities":    ["native", "bitonal", "grey", "color"],   
            "profile":      "http://library.stanford.edu/iiif/image-api/compliance.html#level3"
            }]
          });
        }
        window.onload = initOpenSeadragon;
        document.addEventListener("page:load", initOpenSeadragon); // Initialize when using turbolinks
      EOF

      #<%=javascript_include_tag "openseadragon.js" %>
      content_tag(:div, '', options[:html]) + javascript_tag(js) 
    end
  end
end
