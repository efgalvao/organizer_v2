require 'net/http'
require 'uri'
require 'json'

module BrApi
  class Client
    BASE_URL = ENV.fetch('BRAPI_BASE_URL', 'https://brapi.dev/api')
    TOKEN = ENV.fetch('BRAPI_TOKEN', 'seu_token_aqui')

    def self.get(path)
      uri = URI("#{BASE_URL}#{path}")

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{TOKEN}"
        http.request(request)
      end

      handle_response(response)
    rescue StandardError => e
      Rails.logger.error("BRapi Connection Error: #{e.message}")
      nil
    end

    def self.handle_response(response)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        Rails.logger.error("BRapi Error: #{response.code} - #{response.body}")
        nil
      end
    rescue JSON::ParserError
      Rails.logger.error("BRapi JSON Parse Error: #{response&.body}")
      nil
    end
  end
end
