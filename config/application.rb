require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv only in development or test environment
Dotenv::Railtie.load if %w[development test].include? ENV['RAILS_ENV']

module OrganizerV2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    I18n.available_locales = [:en, :'pt-BR']
    I18n.default_locale = :en

    config.time_zone = "Brasilia"
    config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << Rails.root.join("/app/services")

    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'stylesheets')
  end
end
