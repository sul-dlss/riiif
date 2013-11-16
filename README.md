# Riiif

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
To source the images from the network instead of the file system, we first configure Riiif to use an alternative resolver:
```
      Riiif::Image.file_resolver = Riiif::HTTPFileResolver
```
Then we configure the resolver with a mechanism for mapping the provided id to a url:
```
      Riiif::HTTPFileResolver.id_to_uri = lambda do |id| 
        "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
      end
```
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

For more information see the IIIF spec:

http://www-sul.stanford.edu/iiif/image-api/1.1/
