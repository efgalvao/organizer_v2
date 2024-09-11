Coverband.configure do |config|
  config.ignore += %w[config/application.rb config/boot.rb config/puma.rb bin/* config/environments/* lib/tasks/* spec/* app/channels]
  config.password = ENV['COVERBAND_PASSWORD']
  config.track_routes = true
end
