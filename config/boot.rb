ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

begin
  require "debug" if Rails.env.development? || Rails.env.test?
rescue LoadError
  # ignora em produção
end
