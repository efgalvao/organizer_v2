require 'rails_helper'

RSpec.describe Quotes::FetchQuoteData, type: :service do
  subject(:service) { described_class.new(ticker) }

  let(:ticker) { 'TEST11' }

  describe '#call' do
    context 'when BrApi::FetchStockQuote returns success' do
      let(:quote_data) { { value: 10.0, date: '2023-01-02T15:30:00Z' } }

      before do
        allow(BrApi::FetchStockQuote).to receive(:call).with(ticker).and_return(quote_data)
      end

      it 'returns value and date from integration' do
        result = service.call

        expect(result[:value]).to eq(10.0)
        expect(result[:date]).to eq('2023-01-02T15:30:00Z')
      end
    end

    context 'when BrApi::FetchStockQuote raises InvalidTickerError' do
      before do
        allow(BrApi::FetchStockQuote).to receive(:call).with(ticker)
                                                       .and_raise(BrApi::FetchStockQuote::InvalidTickerError, 'Ticker inválido')
      end

      it 're-raises InvalidTickerError' do
        expect { service.call }.to raise_error(BrApi::FetchStockQuote::InvalidTickerError, 'Ticker inválido')
      end
    end

    context 'when BrApi::FetchStockQuote raises InvalidTickerError with explanatory message' do
      let(:message) { "Ticker #{ticker} não encontrado ou inválido." }

      before do
        allow(BrApi::FetchStockQuote).to receive(:call).with(ticker)
                                                       .and_raise(BrApi::FetchStockQuote::InvalidTickerError, message)
      end

      it 're-raises with same message' do
        expect { service.call }.to raise_error(BrApi::FetchStockQuote::InvalidTickerError) do |error|
          expect(error.message).to include('não encontrado')
          expect(error.message).to include(ticker)
        end
      end
    end
  end
end
