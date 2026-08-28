# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Files::Processors::TransferenceProcessor do
  subject(:processor_call) { described_class.call(content, user_id) }

  let(:user_id) { 1 }

  describe '.call' do
    context 'when delegation' do
      let(:content) { [{ date: '2024-03-16' }] }

      it 'instantiates the processor with content and user_id and invokes #call' do
        instance = instance_double(described_class, call: nil)
        allow(described_class).to receive(:new).with(content, user_id).and_return(instance)

        processor_call

        expect(instance).to have_received(:call)
      end
    end

    context 'when content is blank' do
      before do
        allow(TransferenceRepository).to receive(:find_by)
        allow(Transferences::ProcessRequest).to receive(:call)
      end

      [nil, [], '', false].each do |blank_value|
        context "when content is #{blank_value.inspect}" do
          let(:content) { blank_value }

          it 'does not check for existing transferences' do
            processor_call

            expect(TransferenceRepository).not_to have_received(:find_by)
          end

          it 'does not build any transference request' do
            processor_call

            expect(Transferences::ProcessRequest).not_to have_received(:call)
          end

          it 'returns nil' do
            expect(processor_call).to be_nil
          end
        end
      end
    end

    context 'when content is present' do
      let(:built_transference) do
        { date: '2024-03-16', amount: '1.23', sender_id: 10, receiver_id: 20, user_id: user_id }
      end
      let(:content) { [built_transference] }

      context 'when the transference does not exist yet' do
        before do
          allow(TransferenceRepository).to receive(:find_by).and_return(nil)
          allow(Transferences::ProcessRequest).to receive(:call)
        end

        it 'checks existence using date, amount as decimal, sender_id and receiver_id' do
          processor_call

          expect(TransferenceRepository).to have_received(:find_by).with(
            date: built_transference[:date],
            amount: built_transference[:amount].to_d,
            sender_id: built_transference[:sender_id],
            receiver_id: built_transference[:receiver_id]
          )
        end

        it 'builds the transference request enriching default attributes' do
          processor_call

          expect(Transferences::ProcessRequest).to have_received(:call).with(
            built_transference.merge(
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
              date: '2024-03-16', amount: '1.23', sender_id: 10, receiver_id: 20, user_id: user_id,
              parcels: 3, group: 5, recurrence: 2
            }
          end

          it 'keeps the given parcels, group and recurrence values' do
            processor_call

            expect(Transferences::ProcessRequest).to have_received(:call).with(
              built_transference.merge(type: 'Account::Transference')
            )
          end
        end

        context 'when parcels is explicitly 0' do
          let(:built_transference) do
            { date: '2024-03-16', amount: '1.23', sender_id: 10, receiver_id: 20, user_id: user_id, parcels: 0 }
          end

          it 'keeps parcels as 0, since 0 is truthy in Ruby and is not replaced by ||' do
            processor_call

            expect(Transferences::ProcessRequest).to have_received(:call).with(
              built_transference.merge(group: 0, recurrence: 0, type: 'Account::Transference')
            )
          end
        end

        context 'when group and recurrence are explicitly falsy (false / nil)' do
          let(:built_transference) do
            {
              date: '2024-03-16', amount: '1.23', sender_id: 10, receiver_id: 20, user_id: user_id,
              group: false, recurrence: nil
            }
          end

          it 'replaces group and recurrence with defaults, since false/nil are falsy in Ruby' do
            processor_call

            expect(Transferences::ProcessRequest).to have_received(:call).with(
              built_transference.merge(parcels: 1, group: 0, recurrence: 0, type: 'Account::Transference')
            )
          end
        end
      end

      context 'when the transference already exists' do
        before do
          allow(TransferenceRepository).to receive(:find_by).and_return(instance_double(Account::Transference))
          allow(Transferences::ProcessRequest).to receive(:call)
        end

        it 'does not build a transference request' do
          processor_call

          expect(Transferences::ProcessRequest).not_to have_received(:call)
        end
      end

      context 'when content has nested arrays' do
        let(:transference_a) { { date: '2024-03-16', amount: '1.23', sender_id: 10, receiver_id: 20, user_id: user_id } }
        let(:transference_b) { { date: '2024-03-17', amount: '4.56', sender_id: 30, receiver_id: 40, user_id: user_id } }
        let(:content) { [[transference_a], [transference_b]] }

        before do
          allow(TransferenceRepository).to receive(:find_by).and_return(nil)
          allow(Transferences::ProcessRequest).to receive(:call)
        end

        it 'flattens the content before processing each transference' do
          processor_call

          expect(Transferences::ProcessRequest).to have_received(:call).twice
          expect(Transferences::ProcessRequest).to have_received(:call).with(
            transference_a.merge(parcels: 1, group: 0, recurrence: 0, type: 'Account::Transference')
          )
          expect(Transferences::ProcessRequest).to have_received(:call).with(
            transference_b.merge(parcels: 1, group: 0, recurrence: 0, type: 'Account::Transference')
          )
        end
      end

      context 'when there are multiple transferences' do
        let(:transference_new) do
          { date: '2024-03-16', amount: '1.23', sender_id: 10, receiver_id: 20, user_id: user_id }
        end
        let(:transference_existing) do
          { date: '2024-03-17', amount: '4.56', sender_id: 30, receiver_id: 40, user_id: user_id }
        end
        let(:content) { [transference_new, transference_existing] }

        before do
          allow(TransferenceRepository).to receive(:find_by)
            .with(hash_including(date: '2024-03-16')).and_return(nil)
          allow(TransferenceRepository).to receive(:find_by)
            .with(hash_including(date: '2024-03-17')).and_return(instance_double(Account::Transference))
          allow(Transferences::ProcessRequest).to receive(:call)
        end

        it 'only builds requests for transferences that do not exist yet' do
          processor_call

          expect(Transferences::ProcessRequest).to have_received(:call).once
          expect(Transferences::ProcessRequest).to have_received(:call).with(
            transference_new.merge(parcels: 1, group: 0, recurrence: 0, type: 'Account::Transference')
          )
        end
      end
    end
  end
end
