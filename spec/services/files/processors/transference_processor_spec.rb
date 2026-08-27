require 'rails_helper'

RSpec.describe Files::Processors::TransferenceProcessor do
  subject(:service) { described_class.new(content, user_id) }

  let(:user_id) { 1 }

  describe '.call' do
    it 'instantiates the class and calls #call' do
      instance = instance_double(described_class, call: true)
      allow(described_class).to receive(:new).with('content', user_id).and_return(instance)

      described_class.call('content', user_id)

      expect(instance).to have_received(:call)
    end
  end

  describe '#call' do
    context 'when content is blank' do
      let(:content) { nil }

      it 'does not build transferences' do
        allow(Transferences::BuildRequest).to receive(:call)

        service.call

        expect(Transferences::BuildRequest).not_to have_received(:call)
      end
    end

    context 'when content is an empty array' do
      let(:content) { [] }

      it 'does not build transferences' do
        allow(Transferences::BuildRequest).to receive(:call)

        service.call

        expect(Transferences::BuildRequest).not_to have_received(:call)
      end
    end

    context 'when content is present' do
      let(:content) do
        [{
          sender: 'Conta A',
          receiver: 'Conta B',
          user_id: user_id,
          amount: '1.23',
          date: '2024-03-16'
        }]
      end

      let(:built_transference) do
        {
          sender_id: 10,
          receiver_id: 20,
          user_id: user_id,
          amount: '1.23',
          date: '2024-03-16'
        }
      end

      before do
        allow(Transferences::BuildRequest).to receive(:call).and_return([built_transference])
        allow(Transferences::ProcessRequest).to receive(:call)
        allow(TransferenceRepository).to receive(:find_by).and_return(nil)
      end

      it 'calls Transferences::BuildRequest with content and user_id' do
        service.call

        expect(Transferences::BuildRequest).to have_received(:call).with(content, user_id)
      end

      context 'when the transference does not exist yet' do
        before do
          allow(TransferenceRepository).to receive(:find_by).and_return(nil)
        end

        it 'checks existence using sender_id as account_id' do
          service.call

          expect(TransferenceRepository).to have_received(:find_by).with(
            date: built_transference[:date],
            amount: built_transference[:amount].to_d,
            account_id: built_transference[:sender_id]
          )
        end

        it 'builds the transference request enriching default attributes' do
          service.call

          expect(Transferences::ProcessRequest).to have_received(:call).with(
            hash_including(
              sender_id: built_transference[:sender_id],
              receiver_id: built_transference[:receiver_id],
              user_id: user_id,
              amount: '1.23',
              date: '2024-03-16',
              parcels: 1,
              group: 0,
              recurrence: 0,
              type: 'Account::Transference'
            )
          )
        end

        context 'when transference already has parcels, group and recurrence' do
          let(:built_transference) do
            {
              sender_id: 10,
              receiver_id: 20,
              user_id: user_id,
              amount: '1.23',
              date: '2024-03-16',
              parcels: 3,
              group: 5,
              recurrence: 2
            }
          end

          it 'keeps the given parcels, group and recurrence values' do
            service.call

            expect(Transferences::ProcessRequest).to have_received(:call).with(
              hash_including(
                parcels: 3,
                group: 5,
                recurrence: 2,
                type: 'Account::Transference'
              )
            )
          end
        end
      end

      context 'when the transference already exists' do
        before do
          allow(TransferenceRepository).to receive(:find_by).and_return(instance_double(Transference))
        end

        it 'does not build a new transference request' do
          service.call

          expect(Transferences::ProcessRequest).not_to have_received(:call)
        end
      end

      context 'when there are multiple transferences' do
        let(:existing_transference) do
          {
            sender_id: 30,
            receiver_id: 40,
            user_id: user_id,
            amount: '5.00',
            date: '2024-04-01'
          }
        end

        before do
          allow(Transferences::BuildRequest).to receive(:call).and_return([built_transference, existing_transference])
          allow(TransferenceRepository).to receive(:find_by)
            .with(hash_including(account_id: built_transference[:sender_id]))
            .and_return(nil)
          allow(TransferenceRepository).to receive(:find_by)
            .with(hash_including(account_id: existing_transference[:sender_id]))
            .and_return(instance_double(Transference))
        end

        it 'only builds requests for transferences that do not exist yet' do
          service.call

          expect(Transferences::ProcessRequest).to have_received(:call).once
          expect(Transferences::ProcessRequest).to have_received(:call).with(
            hash_including(sender_id: built_transference[:sender_id])
          )
        end
      end
    end
  end
end
