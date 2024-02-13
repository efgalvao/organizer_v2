module AccountServices
  class CreateAccount
    def initialize(account_params)
      @account_params = account_params
    end

    def self.create(account_params)
      new(account_params).create
    end

    def create
      create_account
    end

    private

    attr_reader :account_params

    def create_account
      account = Account::Account.new(account_params)
      account.save
      account
    end
  end
end
