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

    def fetch_latest_quote
      uri = URI("#{BASE_URL}/quote/#{ticker}")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{BRAPI_TOKEN}"
        http.request(request)
      end
      parsed_response = JSON.parse(response.body)
      validate_response(parsed_response)
      parsed_response
    end

    private

    attr_reader :ticker

    def validate_response(json)
      return unless ticker.strip.upcase != json['results'][0]['symbol'].strip.upcase

      raise InvalidTickerError,
            "Ticker retornado (#{json['results'][0]['symbol']}) não confere com o solicitado (#{ticker})"
    end

    def parse_json(json)
      {
        value: json['results'][0]['regularMarketPrice'],
        date: json['results'][0]['regularMarketTime']
      }
    end
  end
end
