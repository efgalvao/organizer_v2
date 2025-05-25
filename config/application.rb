require_relative 'boot'

require "rails"

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_cable/engine"     # ❌ desative se não usa WebSockets
# require "rails/test_unit/railtie" # ❌ desative se usa RSpec

# Carrega as gems do Gemfile (como antes)
Bundler.require(*Rails.groups)

# Dotenv para dev e test
Dotenv::Railtie.load if %w[development test].include? ENV['RAILS_ENV']

module OrganizerV2
  class Application < Rails::Application
    config.load_defaults 7.0

    I18n.available_locales = [:en, :'pt-BR']
    I18n.default_locale = :'pt-BR'

    config.time_zone = "Brasilia"
    config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << Rails.root.join("app/services")

    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'stylesheets')
  end
end
