module AccountServices
  class UpdateAccount
    def initialize(account_params)
      @account_params = account_params
    end

    def self.update(account_params)
      new(account_params).update
    end

    def update
      update_account
    end

    private

    attr_reader :account_params

    def update_account
      account = Account::Account.find(account_params[:id])
      account.update(account_params)
      account
    end
  end
end
