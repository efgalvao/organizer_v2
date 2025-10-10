module AccountServices
  class FetchAccount
    def initialize(account_id, user_id)
      @account_id = account_id
      @user_id = user_id
    end

    def self.call(account_id, user_id)
      new(account_id, user_id).call
    end

    def call
      account
    end

    private

    attr_reader :user_id, :account_id

    def account
      @account ||= AccountRepository.find_by(id: account_id, user: user_id)
    end
  end
end
