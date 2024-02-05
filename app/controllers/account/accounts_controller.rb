module Account
  class AccountsController < ApplicationController
    before_action :authenticate_user!
    def index
      accounts = Account.where(user_id: current_user.id).except_card_accounts
      @accounts = AccountDecorator.decorate_collection(accounts)
    end
  end
end
