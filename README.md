# Riiif

A Ruby IIIF image server as a rails engine

## Installation

Add this line to your application's Gemfile:

    gem 'riiif'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install riiif

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
