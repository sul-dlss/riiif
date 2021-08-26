module Riiif
  class Routes
    ALLOW_DOTS ||= /[\w.]+/
    SIZES ||= /(!|pct:)?[\w.,]+/

    def initialize(router, options)
      @router = router
      @options = options
    end

    def add_routes(&blk)
      @router.instance_exec(@options, &blk)
    end

    def draw
      add_routes do |options|
        resource = options.fetch(:resource)
        route_prefix = options[:at]
        route_prefix ||= "/#{options[:as]}" if options[:as]

        if route_prefix && route_prefix.starts_with?('http')
          direct options[:as] || 'image' do |opts|
            URI.join(route_prefix, ::File.join(opts[:id], opts[:region] || 'full', opts[:size], opts[:rotation] || '0', "#{opts[:quality] || 'default'}.#{opts[:format] || 'jpg'}")).to_s
          end

          direct [options[:as], 'info'].compact.join('_') do |opts|
            URI.join(route_prefix, ::File.join(opts[:id], 'info.json')).to_s
          end

          direct [options[:as], 'base'].compact.join('_') do |opts|
            URI.join(route_prefix, opts[:id]).to_s
          end
        else
          get "#{route_prefix}/:id/:region/:size/:rotation/:quality.:format" => 'riiif/images#show',
              constraints: { rotation: ALLOW_DOTS, size: SIZES },
              defaults: { format: 'jpg', rotation: '0', region: 'full', quality: 'default', model: resource },
              as: options[:as] || 'image'

          get "#{route_prefix}/:id/info.json" => 'riiif/images#info',
              defaults: { format: 'json', model: resource },
              as: [options[:as], 'info'].compact.join('_')

          match "#{route_prefix}/:id/info.json" => 'riiif/images#info_options',
                via: [:options]

          # This doesn't work presently
          # get "#{route_prefix}/:id", to: redirect("#{route_prefix}/%{id}/info.json")
          get "#{route_prefix}/:id" => 'riiif/images#redirect', as: [options[:as], 'base'].compact.join('_')
        end
      end
    end
  end
end
