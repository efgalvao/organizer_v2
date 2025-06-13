require 'rails_helper'

RSpec.describe InvestmentsServices::FetchStockQuote do
  let(:ticker) { 'PETR4' }
  let(:service) { described_class.new(ticker) }
  let(:base_url) { 'https://brapi.dev/api' }
  let(:token) { 'fake-token' }

  before do
    ENV['BRAPI_BASE_URL'] = base_url
    ENV['BRAPI_TOKEN'] = token
  end

  describe '.call' do
    context 'when API call is successful' do
      let(:successful_response) do
        Struct.new(:status, :body).new(200, {
          'results' => [{
            'symbol' => 'PETR4',
            'regularMarketPrice' => 25.50,
            'regularMarketTime' => 1_641_234_567
          }]
        }.to_json)
      end

      before do
        allow(Net::HTTP).to receive(:start).and_return(successful_response)
      end

      it 'returns quote data' do
        result = described_class.call(ticker)

        expect(result).to eq({
                               value: 25.50,
                               date: 1_641_234_567
                             })
      end
    end

    context 'when ticker is invalid' do
      let(:invalid_response) do
        Struct.new(:status, :body).new(200, {
          'results' => [{
            'symbol' => 'DIFFERENT',
            'regularMarketPrice' => 25.50,
            'regularMarketTime' => 1_641_234_567
          }]
        }.to_json)
      end

      before do
        allow(Net::HTTP).to receive(:start).and_return(invalid_response)
      end

      it 'raises TickerInvalidoError' do
        expect do
          described_class.call(ticker)
        end.to raise_error(InvestmentsServices::FetchStockQuote::InvalidTickerError)
      end
    end
  end
end
