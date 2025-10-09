class AccountRepository
  def all(user_id)
    Account::Account.where(user_id: user_id, type: ['Account::Savings', 'Account::Broker'])
                    .order(:name)
                    .includes(:user)
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

  def find_by_id_and_user(account_id, user_id)
    Account::Account.find_by(id: account_id, user_id: user_id)
  end

  def destroy(id)
    Account::Account.delete(id)
  end

  def by_type_and_user(user_id, account_types)
    Account::Account.where(user_id: user_id, type: account_types)
  end

  def by_user_and_account_id(user_id, account_id = nil)
    query = Account::Account.where(user_id: user_id)
    query = query.where(id: account_id) if account_id
    query
  end

  def expenses_by_category(accounts, date_range)
    Account::Expense.where(account: accounts)
                    .where('date >= ? AND date <= ?', date_range[:start], date_range[:end])
                    .joins(:category)
                    .group('categories.name')
                    .sum(:amount)
  end
end
