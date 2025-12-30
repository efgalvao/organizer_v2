module AccountRepository
  module_function

  ACCOUNT_TYPES = ['Account::Savings', 'Account::Broker'].freeze
  CARD_TYPES = ['Account::Card'].freeze

  def all_by_user(user_id)
    Account::Account.where(user_id: user_id)
                    .order(:name)
                    .includes(:user)
  end

  def by_type_and_user(user_id, account_types)
    query = all_by_user(user_id)
    query = query.where(type: ACCOUNT_TYPES) if account_types == 'accounts'
    query = query.where(type: CARD_TYPES) if account_types == 'cards'
    query
  end

  def create!(attributes)
    Account::Account.create!(attributes)
  end

  def update!(account, attributes)
    account.update!(attributes)
    account
  end

  def find_by(*args)
    Account::Account.find_by(*args)
  end

  def destroy(id)
    Account::Account.delete(id)
  end
end
