require 'open-uri'
require 'active_support/core_ext/file/atomic'

module Riiif
  module HTTPFileResolver

    # Set a lambda that maps the first parameter (id) to a URL
    # Example:
    #
    # Riiif::HTTPFileResolver.id_to_uri = lambda do |id| 
    #  "http://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
    # end
    #
    mattr_accessor :id_to_uri

    mattr_accessor :cache_path
    self.cache_path = 'tmp/network_files'


    def self.find(id)
      remote = RemoteFile.new(uri(id))
      Riiif::File.new(remote.fetch)
    end

    class RemoteFile
      include ActiveSupport::Benchmarkable
      delegate :logger, to: :Rails
      attr_reader :url
      def initialize(url)
        @url = url 
      end

      def fetch
        download_file unless ::File.exist?(file_name)
        file_name
      end

      private

      def ext
        @ext ||= ::File.extname(URI.parse(url).path)
      end

      def file_name
        @cache_file_name ||= ::File.join(HTTPFileResolver.cache_path, Digest::MD5.hexdigest(url)+"#{ext}")
      end

      def download_file
        ensure_cache_path(::File.dirname(file_name))
        benchmark ("Riiif downloaded #{url}") do
          ::File.atomic_write(file_name, HTTPFileResolver.cache_path) do |local| 
            Kernel::open(url) do |remote|
              while chunk = remote.read(8192)
                local.write(chunk)
              end
            end
          end
        end
      end

      # Make sure a file path's directories exist.
      def ensure_cache_path(path)
        FileUtils.makedirs(path) unless ::File.exist?(path)
      end
    end


    protected

      def self.uri(id)
        raise "Must set the id_to_uri lambda" if id_to_uri.nil?
        id_to_uri.call(id)
      end

  end
end
