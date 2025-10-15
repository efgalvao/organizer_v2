module TransactionRepository
  module_function

  def all(account_id, user_id, future: false)
    account = AccountRepository.find_by(id: account_id, user_id: user_id)
    return [] unless account

    scope = account.transactions
                   .includes(:category)
                   .select(:id, :title, :date, :amount, :category_id, :group, :type)
                   .ordered

    future ? scope.future : scope.current_month
  end

  def create!(attributes)
    Account::Transaction.create!(attributes)
  end

  def update!(transaction, attributes)
    transaction.update!(attributes)
    transaction
  end

  def find_by(attributes = {})
    Account::Transaction.find_by(attributes)
  end

  def destroy(id)
    Account::Transaction.delete(id)
  end

  def by_account_and_date_range(account_id, start_date, end_date)
    Account::Transaction.where(account_id: account_id)
                        .where('date >= ? AND date <= ?', start_date, end_date)
  end

  def expenses_by_category(accounts, start_date, end_date)
    Account::Transaction
      .where(account_id: accounts)
      .where(type: 'Account::Expense')
      .where(date: start_date..end_date)
      .joins(:category)
      .group('categories.name')
      .sum(:amount)
  end
end
