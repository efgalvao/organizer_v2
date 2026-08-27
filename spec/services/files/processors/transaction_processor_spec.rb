# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Files::Processors::TransactionProcessor do
  subject(:processor_call) { described_class.call(content) }

  describe '.call' do
    context 'delegation' do
      let(:content) { [{ date: '01/03/2026' }] }

      it 'instantiates the processor with content and invokes #call' do
        instance = instance_double(described_class, call: nil)
        allow(described_class).to receive(:new).with(content).and_return(instance)

        processor_call

        expect(instance).to have_received(:call)
      end
    end

    context 'when content is blank' do
      before do
        allow(Transactions::BuildRequest).to receive(:call)
        allow(Transactions::RequestBuilder).to receive(:call)
      end

      [nil, [], '', false].each do |blank_value|
        context "when content is #{blank_value.inspect}" do
          let(:content) { blank_value }

          it 'does not call BuildRequest' do
            processor_call

            expect(Transactions::BuildRequest).not_to have_received(:call)
          end

          it 'returns nil' do
            expect(processor_call).to be_nil
          end
        end
      end
    end

    context 'when content is present' do
      let(:content) { [{ date: '01/03/2026', amount: '100.0', account_id: 1, type: 'debit' }] }
      let(:built_transaction) do
        { date: '01/03/2026', amount: '100.0', account_id: 1, type: 'debit' }
      end

      before do
        allow(Transactions::BuildRequest).to receive(:call).with(content).and_return([built_transaction])
      end

      context 'when the transaction does not already exist' do
        before do
          allow(Account::Transaction).to receive(:find_by).and_return(nil)
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'calls BuildRequest with the given content' do
          processor_call

          expect(Transactions::BuildRequest).to have_received(:call).with(content)
        end

        it 'checks for an existing transaction using date, amount as decimal, account_id and type' do
          processor_call

          expect(Account::Transaction).to have_received(:find_by).with(
            date: '01/03/2026',
            amount: BigDecimal('100.0'),
            account_id: 1,
            type: 'debit'
          )
        end

        it 'calls RequestBuilder with the transaction enriched with default parcels, group and recurrence' do
          processor_call

          expect(Transactions::RequestBuilder).to have_received(:call).with(
            built_transaction.merge(parcels: 1, group: 0, recurrence: 0)
          )
        end
      end

      context 'when the transaction already exists' do
        before do
          allow(Account::Transaction).to receive(:find_by).and_return(instance_double(Account::Transaction))
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'does not call RequestBuilder' do
          processor_call

          expect(Transactions::RequestBuilder).not_to have_received(:call)
        end

        it 'returns the (empty) result of the each without raising' do
          expect { processor_call }.not_to raise_error
        end
      end

      context 'when account_id is missing but sender_id is present' do
        let(:built_transaction) do
          { date: '01/03/2026', amount: '50.0', sender_id: 2, type: 'transference' }
        end

        before do
          allow(Account::Transaction).to receive(:find_by).and_return(nil)
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'falls back to sender_id when looking up an existing transaction' do
          processor_call

          expect(Account::Transaction).to have_received(:find_by).with(
            date: '01/03/2026',
            amount: BigDecimal('50.0'),
            account_id: 2,
            type: 'transference'
          )
        end
      end

      context 'when the transaction already has parcels, group and recurrence set' do
        let(:built_transaction) do
          { date: '01/03/2026', amount: '100.0', account_id: 1, type: 'debit', parcels: 3, group: 5, recurrence: 2 }
        end

        before do
          allow(Account::Transaction).to receive(:find_by).and_return(nil)
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'preserves the existing values instead of overriding them with defaults' do
          processor_call

          expect(Transactions::RequestBuilder).to have_received(:call).with(built_transaction)
        end
      end

      context 'when parcels is explicitly 0' do
        let(:built_transaction) do
          { date: '01/03/2026', amount: '100.0', account_id: 1, type: 'debit', parcels: 0 }
        end

        before do
          allow(Account::Transaction).to receive(:find_by).and_return(nil)
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'keeps parcels as 0, since 0 is truthy in Ruby and is not replaced by ||' do
          processor_call

          expect(Transactions::RequestBuilder).to have_received(:call).with(
            built_transaction.merge(group: 0, recurrence: 0)
          )
        end
      end

      context 'when group and recurrence are explicitly falsy (false / nil)' do
        let(:built_transaction) do
          { date: '01/03/2026', amount: '100.0', account_id: 1, type: 'debit', group: false, recurrence: nil }
        end

        before do
          allow(Account::Transaction).to receive(:find_by).and_return(nil)
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'replaces group and recurrence with defaults, since false/nil are falsy in Ruby' do
          processor_call

          expect(Transactions::RequestBuilder).to have_received(:call).with(
            built_transaction.merge(parcels: 1, group: 0, recurrence: 0)
          )
        end
      end

      context 'when BuildRequest returns nested arrays' do
        let(:transaction_a) { { date: '01/03/2026', amount: '10.0', account_id: 1, type: 'debit' } }
        let(:transaction_b) { { date: '02/03/2026', amount: '20.0', account_id: 1, type: 'credit' } }

        before do
          allow(Transactions::BuildRequest).to receive(:call).with(content).and_return([[transaction_a], [transaction_b]])
          allow(Account::Transaction).to receive(:find_by).and_return(nil)
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'flattens the result before processing each transaction' do
          processor_call

          expect(Transactions::RequestBuilder).to have_received(:call).twice
          expect(Transactions::RequestBuilder).to have_received(:call).with(
            transaction_a.merge(parcels: 1, group: 0, recurrence: 0)
          )
          expect(Transactions::RequestBuilder).to have_received(:call).with(
            transaction_b.merge(parcels: 1, group: 0, recurrence: 0)
          )
        end
      end

      context 'when there is a mix of new and already existing transactions' do
        let(:transaction_new) { { date: '01/03/2026', amount: '10.0', account_id: 1, type: 'debit' } }
        let(:transaction_existing) { { date: '02/03/2026', amount: '20.0', account_id: 1, type: 'credit' } }

        before do
          allow(Transactions::BuildRequest).to receive(:call).with(content).and_return([transaction_new, transaction_existing])
          allow(Account::Transaction).to receive(:find_by).with(hash_including(date: '01/03/2026')).and_return(nil)
          allow(Account::Transaction).to receive(:find_by).with(hash_including(date: '02/03/2026'))
                                                          .and_return(instance_double(Account::Transaction))
          allow(Transactions::RequestBuilder).to receive(:call)
        end

        it 'only builds requests for transactions that do not already exist' do
          processor_call

          expect(Transactions::RequestBuilder).to have_received(:call).once
          expect(Transactions::RequestBuilder).to have_received(:call).with(
            transaction_new.merge(parcels: 1, group: 0, recurrence: 0)
          )
        end
      end
    end
  end
end
