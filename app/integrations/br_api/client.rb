module BrApi
  class Client
    BASE_URL = ENV.fetch('BRAPI_BASE_URL', 'https://brapi.dev/api')
    TOKEN = ENV.fetch('BRAPI_TOKEN', 'seu_token_aqui')

    def self.get(path)
      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(token: TOKEN)

      response = Net::HTTP.get_response(uri)

      handle_response(response)
    end

    def self.handle_response(response)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        Rails.logger.error("BRapi Error: #{response.code} - #{response.body}")
        nil
      end
    end
  end
end
