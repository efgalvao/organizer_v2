require 'net/http'
require 'json'

module InvestmentsServices
  class FetchStockQuote < ApplicationService
    class InvalidTickerError < StandardError; end

    BASE_URL = ENV.fetch('BRAPI_BASE_URL', 'base_url')
    BRAPI_TOKEN = ENV.fetch('BRAPI_TOKEN', 'my_token')

    def initialize(ticker)
      @ticker = ticker
    end

    def self.call(ticker)
      new(ticker).call
    end

    def call
      json = fetch_latest_quote
      return nil unless json

      parse_json(json)
    end

    private

    attr_reader :ticker

    def fetch_latest_quote
      uri = URI("#{BASE_URL}/quote/#{ticker}")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{BRAPI_TOKEN}"
        http.request(request)
      end
      Rails.logger.info("Fetch Quote Response: #{response.body}")
      unless response.is_a?(Net::HTTPSuccess)
        raise InvalidTickerError, I18n.t('investments.investments.show.fetch_quote_error')
      end

      parsed_response = JSON.parse(response.body)
      validate_response!(parsed_response)
      parsed_response
    rescue JSON::ParserError
      raise InvalidTickerError, I18n.t('investments.investments.show.fetch_quote_error')
    end

    def validate_response!(json)
      raise InvalidTickerError, I18n.t('investments.investments.show.fetch_quote_error') if json['results'].blank?

      returned_symbol = json['results'][0]['symbol'].to_s.strip.upcase
      requested = ticker.to_s.strip.upcase
      return unless returned_symbol != requested

      raise InvalidTickerError,
            "Ticker retornado (#{json['results'][0]['symbol']}) não confere com o solicitado (#{ticker})"
    end

    def parse_json(json)
      result = json['results'][0]
      time = result['regularMarketTime']

      {
        value: result['regularMarketPrice'],
        date: time
      }
    end
  end
end
