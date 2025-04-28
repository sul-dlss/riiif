require 'simplecov'

SimpleCov.start('rails')

require 'engine_cart'
ENV['RAILS_ENV'] ||= 'test'

EngineCart.load_application!
require 'rspec/rails'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true

  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  module Vips
    class Image
      # Left intentionally blank.
      #
      # This is here to prevent uninitialized constant errors when vips is not
      # installed. Adding "require 'ruby-vips'" to specs will throw errors if
      # vips is not installed.
    end
  end
end
