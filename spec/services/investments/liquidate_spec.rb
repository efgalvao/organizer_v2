# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Investments::Liquidate do
  subject(:liquidate) { described_class.call(investment.id) }

  let(:user) { create(:user) }
  let(:account) { create(:account, user: user) }
  let!(:investment) { create(:investment, account: account, released: false) }

  describe '.call' do
    it 'marks the investment as released', :aggregate_failures do
      response = liquidate[0]

      expect(response).to be_a(Investments::Investment)
      expect(response.id).to eq(investment.id)
      expect(response).to be_persisted
      expect(response.released).to be true
    end

    it 'persists released: true in the database' do
      liquidate

      expect(investment.reload.released).to be true
    end

    it 'delegates to Investments::Update with id and released: true' do
      update_params = { id: investment.id, released: true }
      allow(Investments::Update).to receive(:call).and_call_original

      liquidate

      expect(Investments::Update).to have_received(:call).with(update_params)
    end

    context 'when investment is already released' do
      let!(:investment) { create(:investment, account: account, released: true) }

      it 'returns the investment and keeps it released' do
        response = liquidate[0]

        expect(response.released).to be true
        expect(investment.reload.released).to be true
      end
    end

    context 'when investment does not exist' do
      subject(:liquidate) { described_class.call(0) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { liquidate }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
