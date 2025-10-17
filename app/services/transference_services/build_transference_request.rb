module TransferenceServices
  class BuildTransferenceRequest
    def initialize(transferences, user_id)
      @transferences = transferences
      @user_id = user_id
    end

    def self.call(transferences, user_id)
      new(transferences, user_id).call
    end

    def call
      build_transferences
    end

    private

    attr_reader :transferences, :user_id

    def build_transferences
      transferences.map do |transference|
        build_transference(transference)
      end
    end

    def build_transference(transference)
      {
        sender_id: account_id(transference[:sender]),
        receiver_id: account_id(transference[:receiver]),
        date: transference[:date],
        amount: transference[:amount],
        user_id: user_id
      }
    end

    def account_id(account_name)
      downcased_name = account_name.downcase.strip
      AccountRepository.find_by('LOWER(name) = ?', downcased_name)&.id
    end
  end
end
