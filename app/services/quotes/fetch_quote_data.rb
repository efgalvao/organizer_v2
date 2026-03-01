module Quotes
  class FetchQuoteData < ApplicationService
    def initialize(ticker)
      @ticker = ticker
    end

    def self.call(ticker)
      new(ticker).call
    end

    def call
      BrApi::FetchStockQuote.call(ticker)
    rescue BrApi::FetchStockQuote::InvalidTickerError => e
      Rails.logger.error("[FetchQuoteData] Error: #{e.message}")
      raise e
    end

    private

    attr_reader :ticker
  end
end
