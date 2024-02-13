module Account
  class AccountReport < ApplicationRecord
    belongs_to :account, class_name: 'Account::Account'
  end
end
