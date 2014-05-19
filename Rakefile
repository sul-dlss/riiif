require "bundler/gem_tasks"
require 'bundler/setup'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'engine_cart/rake_task'
task :ci => ['engine_cart:generate'] do
  # run the tests
end
