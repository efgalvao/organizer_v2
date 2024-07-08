module TransferenceServices
  class BuildTransferenceRequest
    def initialize(csv_strings, user_id)
      @csv_strings = csv_strings
      @user_id = user_id
    end

    def self.call(csv_strings, user_id)
      new(csv_strings, user_id).call
    end

    def call
      build_transferences
    end

    private

    attr_reader :csv_strings, :user_id

    def build_transferences
      csv_strings.map do |csv_string|
        transference_params = build_params(csv_string)
        build_transference(transference_params)
      end
    end

    def build_params(csv_string)
      keys = %i[sender receiver value date]
      values = csv_string.split(',')
      keys.zip(values).to_h
    end

    def build_transference(transference)
      {
        sender_id: account_id(transference[:sender]),
        receiver_id: account_id(transference[:receiver]),
        date: transference[:date],
        value_cents: transference[:value],
        user_id: user_id
      }
    end

    def account_id(account_name)
      downcased_name = account_name.downcase.strip
      Account::Account.find_by('LOWER(name) = ?', downcased_name)&.id
    end
  end
end
