# frozen_string_literal: true

module AccountServices
  class UpdateAccountBalance
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      update_balance
    end

    private

    attr_reader :params

    def account
      @account ||= AccountRepository.new.find_by(id: params[:account_id])
    end

    def update_balance
      account.update(update_params)
      account
    end

    def update_params
      {
        balance: new_balance
      }
    end

    def new_balance
      account.balance + params[:amount]
    end
  end
end
