# Riiif
[![Gem Version](https://badge.fury.io/rb/riiif.png)](http://badge.fury.io/rb/riiif)

A Ruby IIIF image server as a rails engine

## Installation

RIIIF depends on Imagemagick so you must install that first. On a mac using Homebrew you can follow these instructions:

ImageMagick (6.8.8) may be installed with a few options:
* `--with-ghostscript` Compile with Ghostscript for Postscript/PDF support
* `--with-tiff` Compile with libtiff support for TIFF files
* `--with-jp2` Compile with openjpeg2 support for jpeg2000

```bash
brew install imagemagick --with-ghostscript --with-tiff --with-jp2
```

## Install the gem
Add this line to your application's Gemfile:

    gem 'riiif'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install riiif
    
## Configure

### Images on the servers file system.

By default Riiif is set to load images from the filesystem using the Riiif::FileSystemFileResolver. 
You can configure how this resolver finds the files by setting this property:
```
    Riiif::Image.file_resolver.base_path = '/opt/repository/images/'
```
When the Id passed in is "foo_image", then it will look for an image file using this glob: 
```
/opt/repository/images/foo_image.{png,jpg,tiff,jp,jp2}
```

### Images retrieved over HTTP
It's preferable to use files on the filesystem, because this avoids the overhead of downloading the file.  If this is unavoidable, Riiif can be configured to fetch files from the network.  To enable this behavior, configure Riiif to use an alternative resolver:
```
      Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new
```
Then we configure the resolver with a mechanism for mapping the provided id to a url:
```
      Riiif::Image.file_resolver.id_to_uri = lambda do |id|
        "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
      end
```
If you need to use HTTP basic authentication you can enable it like this:
```
      Riiif::Image.file_resolver.basic_auth_credentials = ['username', 's0s3kr3t']
```

This file resolver caches the network files, so you will want to clear out the old files or the cache will expand until you run out of disk space.
Using a script like this would be a good idea: https://github.com/pulibrary/loris/blob/607567b921404a15a2111fbd7123604f4fdec087/bin/loris-cache_clean.sh
By default the cache is located in `tmp/network_files`. You can set the cache path like this: `Riiif::Image.file_resolver.cache_path = '/var/cache'`

## Usage

Add the routes to your application by inserting the following line into `config/routes.rb` 
```
  mount Riiif::Engine => '/image-service', as: 'riiif'
```

Then you can make requests like this:

* http://www.example.org/image-service/abcd1234/full/full/0/default.jpg
* http://www.example.org/image-service/abcd1234/full/100,/0/default.jpg
* http://www.example.org/image-service/abcd1234/full/,100/0/default.jpg
* http://www.example.org/image-service/abcd1234/full/pct:50/0/default.jpg
* http://www.example.org/image-service/abcd1234/full/150,75/0/default.jpg
* http://www.example.org/image-service/abcd1234/full/!150,75/0/default.jpg

### Route helpers

It is prefereable that you use the provided route helpers to build these URIs. Here's an example:

```ruby
  image_tag(Riiif::Engine.routes.url_helpers.image_path(file_id, size: ',600'))
```

### Using a default image

If there is a request for an id that doesn't exist, a 404 will be returned. You can optionally return an image with this 404 by setting this in your initializer:

```ruby
Riiif::not_found_image = 'path/to/image.png'
```

You can do this to create a default Riiif::Image to use (useful for passing "missing" images to openseadragon_collection_viewer):

```ruby
Riiif::Image.new('no_image', Riiif::File.new(Riiif.not_found_image))
```

## Authorization

The controller will call an authorization service with the controller context.  This service must have a method `can?(action, image)` which returns a boolean. The default service is the `RIIIF::NilAuthrorizationService` which permits all requests. 

In this example we've dissallowed all requests:

```ruby
class NoService
  def initalize(controller)
  end

  def can?(action, image)
    false
  end
end

Riiif::Image.authorization_service = NoService
```

## Integration with Hydra/Fedora

Create an initializer like this in `config/initializers/riiif_initializer.rb`

```ruby
# Tell RIIIF to get files via HTTP (not from the local disk)
Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new

# This tells RIIIF how to resolve the identifier to a URI in Fedora
DATASTREAM = 'imageContent'
Riiif::Image.file_resolver.id_to_uri = lambda do |id| 
  connection = ActiveFedora::Base.connection_for_pid(id)
  host = connection.config[:url]
  path = connection.api.datastream_content_url(id, DATASTREAM, {})
  host + '/' + path
end

# In order to return the info.json endpoint, we have to have the full height and width of
# each image. If you are using hydra-file_characterization, you have the height & width 
# cached in Solr. The following block directs the info_service to return those values:
HEIGHT_SOLR_FIELD = 'height_isi'
WIDTH_SOLR_FIELD = 'width_isi'
Riiif::Image.info_service = lambda do |id, file|
  resp = get_solr_response_for_doc_id id
  doc = resp.first['response']['docs'].first
  { height: doc[HEIGHT_SOLR_FIELD], width: doc[WIDTH_SOLR_FIELD] }
end

include Blacklight::SolrHelper
def blacklight_config
  CatalogController.blacklight_config
end

### ActiveSupport::Benchmarkable (used in Blacklight::SolrHelper) depends on a logger method

def logger
  Rails.logger
end


Riiif::Engine.config.cache_duration_in_days = 30
```


## Running the tests
First, build the engine
```bash
rake engine_cart:generate
```

Run the tests
```bash
rake spec
```


## For more information
see the IIIF spec:

http://www-sul.stanford.edu/iiif/image-api/1.1/
