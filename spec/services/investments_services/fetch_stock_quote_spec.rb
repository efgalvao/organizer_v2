require 'rails_helper'

RSpec.describe InvestmentsServices::FetchStockQuote, type: :service do
  subject(:service) { described_class.new(ticker) }

  let(:http) { double('http') }
  let(:ticker) { 'TEST11' }

  def stub_http_response(body:, success: true)
    response = double('response', body: body)
    allow(response).to receive(:is_a?) do |klass|
      klass == Net::HTTPSuccess ? success : false
    end

    allow(http).to receive(:request).and_return(response)
    allow(Net::HTTP).to receive(:start).and_yield(http).and_return(response)
  end

  describe '#call / #fetch_latest_quote' do
    context 'when API returns success with parsable time string' do
      let(:time_str) { '2023-01-02T15:30:00Z' }
      let(:json) do
        {
          'results' => [
            {
              'symbol' => ticker,
              'regularMarketPrice' => 10.0,
              'regularMarketTime' => time_str
            }
          ]
        }.to_json
      end

      it 'parses value and parses time string into Time.zone' do
        stub_http_response(body: json, success: true)

        result = service.call
        expect(result[:value]).to eq(10.0)
        expect(result[:date]).to eq(time_str)
      end
    end

    context 'when API returns non-success HTTP response' do
      let(:json) { '{}'.to_json }

      it 'raises InvalidTickerError' do
        stub_http_response(body: json, success: false)

        expect { service.call }.to raise_error(InvestmentsServices::FetchStockQuote::InvalidTickerError)
      end
    end

    context 'when response body is not valid JSON' do
      it 'raises InvalidTickerError' do
        stub_http_response(body: 'not json', success: true)

        expect { service.call }.to raise_error(InvestmentsServices::FetchStockQuote::InvalidTickerError)
      end
    end

    context 'when results are empty or nil' do
      it 'raises InvalidTickerError for empty results' do
        stub_http_response(body: { 'results' => [] }.to_json, success: true)

        expect { service.call }.to raise_error(InvestmentsServices::FetchStockQuote::InvalidTickerError)
      end

      it 'raises InvalidTickerError for nil results' do
        stub_http_response(body: { 'results' => nil }.to_json, success: true)

        expect { service.call }.to raise_error(InvestmentsServices::FetchStockQuote::InvalidTickerError)
      end
    end

    context 'when returned symbol does not match requested' do
      let(:json) do
        {
          'results' => [
            {
              'symbol' => 'OTHER',
              'regularMarketPrice' => 1.0,
              'regularMarketTime' => 1_700_000_000
            }
          ]
        }.to_json
      end

      it 'raises InvalidTickerError with explanatory message' do
        stub_http_response(body: json, success: true)

        expect { service.call }.to raise_error do |error|
          expect(error).to be_a(InvestmentsServices::FetchStockQuote::InvalidTickerError)
          expect(error.message).to include('Ticker retornado')
          expect(error.message).to include(ticker)
        end
      end
    end
  end
end
