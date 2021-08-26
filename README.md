# Riiif
[![Gem Version](https://badge.fury.io/rb/riiif.png)](http://badge.fury.io/rb/riiif)
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/riiif/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/riiif?branch=master)


A Ruby IIIF image server as a rails engine. Note that RIIIF is meant for development convenience and will not scale to the needs of most production-level applications.

## Installation

RIIIF depends on Imagemagick so you must install that first. On a mac using Homebrew you can follow these instructions:

ImageMagick (7.0.4) may be installed with a few options:
* `--with-ghostscript` Compile with Ghostscript for Postscript/PDF support
* `--with-tiff` Compile with libtiff support for TIFF files
* `--with-openjpeg` Compile with openjpeg2 support for jpeg2000

```bash
brew install imagemagick --with-ghostscript --with-tiff --with-openjpeg
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
      Riiif::Image.file_resolver = Riiif::HttpFileResolver.new
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
### Kakadu (for faster jp2 decoding)
To configure Riiif to use Kakadu set:

```ruby
Riiif::Engine.config.kakadu_enabled = true
```

See [benchmark](docs/benchmark.md) for details

### GraphicsMagick

To use [GraphicsMagick](http://www.graphicsmagick.org/) instead of ImageMagick

    Riiif::ImagemagickCommandFactory.external_command = "gm convert"
    Riiif::ImageMagickInfoExtractor.external_command  = "gm identify"

You will of course need to install GraphicsMagick on your system.

### Images hosted at an external IIIF endpoint

You can also configure RIIIF to point at an existing IIIF server, which sends users
directly to that service for retrieving images while preserving API compatibility with
RIIIF.

```ruby
# Configure the RIIIF routes to use the external provider
Riiif::Engine.config.iiif_routes = { at: 'https://stacks.stanford.edu/image/iiif/' }

# Configure an info service to request data from the external IIIF service, using the
# HTTP client library of your choice (shown here using Faraday):
Riiif::Image.info_service = lambda do |id, image|
  Riiif::Image.cache.fetch(Riiif::Image.cache_key(id, info: true), compress: true, expires_in: Riiif::Image.expires_in) do
    route_prefix = Riiif::Engine.config.iiif_routes[:at]
    uri = URI.join(route_prefix, ::File.join(id, 'info.json')).to_s
    JSON.parse(Faraday.get(uri).body).with_indifferent_access
  end
end

# Stub out the file resolver, the output of which is unused in this configuration
Riiif::Image.file_resolver = Class.new do
  def initialize(*_args); end
  def find(*_args); end
end.new
```

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

### Using default images for missing and unauthorized requests

If there is a request for an id that doesn't exist, a 404 will be
returned. You can optionally return an image with this 404 by setting
this in your initializer:

```ruby
Riiif.not_found_image = 'path/to/image.png'
```

If the request is unauthorized, a 401 will be returned, and a custom
error image can also be configured.

```ruby
Riiif.unauthorized_image = 'path/to/unauthorized_image.png'
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
Riiif::Image.file_resolver = Riiif::HttpFileResolver.new

# This tells RIIIF how to resolve the identifier to a URI in Fedora
Riiif::Image.file_resolver.id_to_uri = lambda do |id|
  ActiveFedora::Base.id_to_uri(CGI.unescape(id)).tap do |url|
    logger.info "Riiif resolved #{id} to #{url}"
  end
end

# In order to return the info.json endpoint, we have to have the full height and width of
# each image. If you are using hydra-file_characterization, you have the height & width
# cached in Solr. The following block directs the info_service to return those values:
Riiif::Image.info_service = lambda do |id, file|
  # id will look like a path to a pcdm:file
  # (e.g. rv042t299%2Ffiles%2F6d71677a-4f80-42f1-ae58-ed1063fd79c7)
  # but we just want the id for the FileSet it's attached to.

  # Capture everything before the first slash
  fs_id = id.sub(/\A([^\/]*)\/.*/, '\1')
  resp = ActiveFedora::SolrService.get("id:#{fs_id}")
  doc = resp['response']['docs'].first
  raise "Unable to find solr document with id:#{fs_id}" unless doc

  # You’ll want default values if you make thumbnails of PDFs or other
  # file types that `identify` won’t return dimensions for
  {
    height: doc["height_is"] || 100,
    width: doc["width_is"] || 100,
    format: doc["mime_type_ssi"],
  }
end

def logger
  Rails.logger
end

# Note that this is translated to an `expires` argument to the
# ActiveSupport::Cache::Store in use, by default the host application's
# Rails.cache. Some cache stores may not automatically purge expired content,
# such as the default FileStore.
# http://guides.rubyonrails.org/caching_with_rails.html#cache-stores
Riiif::Engine.config.cache_duration = 30.days
```
#### Special note for Passenger and Apache users
If you are running riiif in Passenger under Apache, you must set the following in your virtual host definition:

```
AllowEncodedSlashes NoDecode
```

You may also need to set the following in your virtual host definition, either at the top level, or within a
Location block for a specific path. See the [Passenger configuration reference](https://www.phusionpassenger.com/library/config/apache/reference/#passengerallowencodedslasheshttps://www.phusionpassenger.com/library/config/apache/reference/#passengerallowencodedslashes) for more info.

```
PassengerAllowEncodedSlashes on
```

An alternative approach to `PassengerAllowEncodedSlashes on` is to explicitly decode the url, like this:

```ruby
require "uri"
fs_id = URI.decode(id).sub(/\A([^\/]*)\/.*/, '\1')
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
