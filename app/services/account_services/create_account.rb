module AccountServices
  class CreateAccount
    def self.create(account_params)
      create_account(account_params)
    end

    def self.create_account(account_params)
      account = Account::Account.new(account_params)
      account.save
      account
    end
  end
end
