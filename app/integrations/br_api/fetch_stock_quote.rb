module BrApi
  class FetchStockQuote < ApplicationService
    class InvalidTickerError < StandardError; end

    def initialize(ticker)
      @ticker = ticker.to_s.strip.upcase
    end

    def self.call(ticker)
      new(ticker).call
    end

    def call
      data = BRapi::Client.get("/quote/#{ticker}")

      raise InvalidTickerError, I18n.t('investments.errors.fetch_quote_error') if data.nil?

      validate_response!(data)
      parse_json(data)
    end

    private

    attr_reader :ticker

    def validate_response!(json)
      results = json['results']
      return unless results.blank? || results[0]['symbol'].upcase != ticker

      raise InvalidTickerError, "Ticker #{ticker} não encontrado ou inválido."
    end

    def parse_json(json)
      result = json['results'][0]
      {
        value: result['regularMarketPrice'],
        date: result['regularMarketTime']
      }
    end
  end
end
