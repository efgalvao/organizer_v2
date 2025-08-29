ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

if %w[development test].include?(ENV["RAILS_ENV"])
  begin
    require "debug"
  rescue LoadError
    # ignora em produção
  end
end
