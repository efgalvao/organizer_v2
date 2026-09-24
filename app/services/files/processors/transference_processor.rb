module Files
  module Processors
    class TransferenceProcessor
      TRANSFERENCE_TYPE = 'Transaction::Transference'.freeze

      def initialize(content, user_id)
        @content = content
        @user_id = user_id
      end

      def self.call(content, user_id)
        new(content, user_id).call
      end

      def call
        process_transferences if (content.presence || []).any?
      end

      private

      attr_reader :content, :user_id

      def process_transferences
        transferences = content
        transferences.flatten.each do |transference|
          next unless process_transference?(transference)

          Transferences::ProcessRequest.call(enrich_transference_params(transference))
        end
      end

      def process_transference?(transference)
        TransferenceRepository.find_by(
          date: transference[:date],
          amount: transference[:amount].to_d,
          receiver_id: transference[:receiver_id],
          sender_id: transference[:sender_id]
        ).nil?
      end

      def enrich_transference_params(transference)
        transference.merge(
          parcels: transference[:parcels] || 1,
          group: transference[:group] || 0,
          recurrence: transference[:recurrence] || 0,
          type: TRANSFERENCE_TYPE
        )
      end
    end
  end
end
