require 'rails_helper'

RSpec.describe Invoices::ProcessPayment do
  let(:sender) { create(:account, balance: 500.0, name: 'Conta Corrente') }
  let(:receiver) { create(:account, balance: 0.0, name: 'Cartão de Crédito') }
  let(:date) { '2026-03-01' }
  let(:amount) { 100.11 }

  let(:params) do
    {
      sender_id: sender.id,
      receiver_id: receiver.id,
      amount: amount.to_s,
      date: date
    }
  end

  describe '.call' do
    subject(:execute_service) { described_class.call(params) }

    context 'when attributes are valid' do
      it 'process correctly payment and adjut balances', :aggregate_failures do
        expect(execute_service).to be_valid
        expect(sender.reload.balance).to eq(399.89)
        expect(receiver.reload.balance).to eq(100.11)
      end

      it 'create two transactions' do
        expect { execute_service }.to change(Account::Transaction, :count).by(2)
      end
    end

    context 'when has error in processing' do
      before do
        allow(Transactions::ProcessRequest).to receive(:call)
          .and_wrap_original do |method, args|
            method.call(args) if args[:value_to_update_balance] < 0
            raise StandardError, 'Erro inesperado na segunda perna' if args[:value_to_update_balance] > 0
          end
      end

      it 'does not change balance' do
        expect { execute_service }.not_to change { sender.reload.balance }
        expect(receiver.reload.balance).to eq(0.0)
      end

      it 'return false' do
        expect(execute_service).to be false
      end
    end

    context 'when date is not informed' do
      let(:date) { nil }

      it 'utiliza a data atual do sistema' do
        execute_service
        last_transaction = Account::Transaction.last
        expect(last_transaction.date).to eq(Time.zone.today)
      end
    end

    context 'when ammount is not informed' do
      let(:amount) { nil }

      it 'does not change accounts balances', :aggregate_failures do
        execute_service

        expect(sender.reload.balance).to eq(500)
        expect(receiver.reload.balance).to eq(0)
      end
    end
  end
end
