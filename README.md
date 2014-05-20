# Riiif
[![Gem Version](https://badge.fury.io/rb/riiif.png)](http://badge.fury.io/rb/riiif)

A Ruby IIIF image server as a rails engine

## Installation

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
    Riiif::FileSystemFileResolver.base_path = '/opt/repository/images/'
```
When the Id passed in is "foo_image", then it will look for an image file using this glob: 
```
/opt/repository/images/foo_image.{png,jpg,tiff,jp,jp2}
```

### Images retrieved over HTTP
It's preferable to use files on the filesystem, because this avoids the overhead of downloading the file.  If this is unavoidable, Riiif can be configured to fetch files from the network.  To enable this behavior, configure Riiif to use an alternative resolver:
```
      Riiif::Image.file_resolver = Riiif::HTTPFileResolver
```
Then we configure the resolver with a mechanism for mapping the provided id to a url:
```
      Riiif::HTTPFileResolver.id_to_uri = lambda do |id| 
        "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
      end
```

This file resolver caches the network files, so you will want to clear out the old files or the cache will expand until you run out of disk space.
Using a script like this would be a good idea: https://github.com/pulibrary/loris/blob/607567b921404a15a2111fbd7123604f4fdec087/bin/loris-cache_clean.sh
By default the cache is located in `tmp/network_files`. You can set the cache path like this: `Riiif::HTTPFileResolver.cache_path = '/var/cache'`

## Usage

Mount the gem as an engine:
```
mount Riiif::Engine => '/image-service'
```

Then you can make requests like this:

* http://www.example.org/image-service/abcd1234/full/full/0/native.jpg
* http://www.example.org/image-service/abcd1234/full/100,/0/native.jpg
* http://www.example.org/image-service/abcd1234/full/,100/0/native.jpg
* http://www.example.org/image-service/abcd1234/full/pct:50/0/native.jpg
* http://www.example.org/image-service/abcd1234/full/150,75/0/native.jpg
* http://www.example.org/image-service/abcd1234/full/!150,75/0/native.jpg

### Using a default image

If there is a request for an id that doesn't exist, a 404 will be returned. You can optionally return an image with this 404 by setting this in your initializer:

```ruby
Riiif::not_found_image = 'path/to/image.png'
```

You can do this to create a default Riiif::Image to use (useful for passing "missing" images to openseadragon_collection_viewer):

```ruby
Riiif::Image.new('no_image', Riiif::File.new(Riiif.not_found_image))
```

## Running the tests
First, build the engine
```bash
rake engine_cart:generate
```

ImageMagick must be installed with jasper support
```bash
brew install imagemagick --with-jasper # if using Homebrew
```
It appears that as of imagemagick 6.8.8 you have to use openjpeg2 instead of jasper:
http://www.imagemagick.org/discourse-server/viewtopic.php?f=2&t=25357#p109912
This doesn't appear to be possible on homebrew until this ticket gets closed: https://github.com/Homebrew/homebrew/issues/28153

Run the tests
```bash
rake spec
```


## For more information
see the IIIF spec:

http://www-sul.stanford.edu/iiif/image-api/1.1/
