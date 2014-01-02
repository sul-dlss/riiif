require 'spec_helper'

describe Riiif::OpenseadragonHelper do

  it "should draw the single item viewer" do
    out = openseadragon_viewer('world', image_host: '/foo', html: {class: 'stuff'})
    out.should == '<div class="stuff" id="openseadragon1"></div><script>
//<![CDATA[
        function initOpenSeadragon() {
          OpenSeadragon({
  "id": "openseadragon1",
  "prefixUrl": "/assets/openseadragon/",
  "tileSources": [
    {
      "identifier": "world",
      "width": 800,
      "height": 400,
      "scale_factors": [
        1,
        2,
        3,
        4,
        5
      ],
      "formats": [
        "jpg",
        "png"
      ],
      "qualities": [
        "native",
        "bitonal",
        "grey",
        "color"
      ],
      "profile": "http://library.stanford.edu/iiif/image-api/compliance.html#level3",
      "tile_width": 1024,
      "tile_height": 1024,
      "image_host": "/foo"
    }
  ]
});
        }
        window.onload = initOpenSeadragon;
        document.addEventListener("page:load", initOpenSeadragon); // Initialize when using turbolinks

//]]>
</script>'
  end

  it "should not crash when there's no tileSources" do
    openseadragon_collection_viewer(['world', 'irises'], {extraOption: :some_stuff})
  end

  it "should draw the collection viewer" do
    out = openseadragon_collection_viewer(['world', 'irises'],
                                          {tileSources: [{profile: :foo}, {profile: :bar}],
                                           extraOption: :some_stuff})
    out.should == '<div id="openseadragon1"></div><script>
//<![CDATA[
        function initOpenSeadragon() {
          OpenSeadragon({
  "id": "openseadragon1",
  "prefixUrl": "/assets/openseadragon/",
  "tileSources": [
    {
      "identifier": "world",
      "width": 800,
      "height": 400,
      "scale_factors": [
        1,
        2,
        3,
        4,
        5
      ],
      "formats": [
        "jpg",
        "png"
      ],
      "qualities": [
        "native",
        "bitonal",
        "grey",
        "color"
      ],
      "profile": "foo",
      "tile_width": 1024,
      "tile_height": 1024,
      "image_host": "/image-service"
    },
    {
      "identifier": "irises",
      "width": 4264,
      "height": 3282,
      "scale_factors": [
        1,
        2,
        3,
        4,
        5
      ],
      "formats": [
        "jpg",
        "png"
      ],
      "qualities": [
        "native",
        "bitonal",
        "grey",
        "color"
      ],
      "profile": "bar",
      "tile_width": 1024,
      "tile_height": 1024,
      "image_host": "/image-service"
    }
  ],
  "extraOption": "some_stuff"
});
        }
        window.onload = initOpenSeadragon;
        document.addEventListener("page:load", initOpenSeadragon); // Initialize when using turbolinks

//]]>
</script>'
  end
end
