module AccountServices
  class UpdateAccount
    def self.update(account_params)
      update_account(account_params)
    end

    private

    def self.update_account(account_params)
      account = Account::Account.find(account_params[:id])
      account.update(account_params)
      account
    end
  end
end
