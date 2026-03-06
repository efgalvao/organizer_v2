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

  def for_user_account(account_id, user_id, future: false)
    all(account_id, user_id, future: future)
  end

  def update!(transaction, attributes)
    transaction.update!(attributes)
    transaction
  end

  def find_by(attributes = {})
    Account::Transaction.find_by(attributes)
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

  def for_user_in_current_month(user_id, groups: nil, categories: nil)
    scope = Account::Transaction
            .joins(:account, :category)
            .where(accounts: { user_id: user_id })
            .where(
              'date >= ? AND date <= ?',
              Time.zone.today.beginning_of_month,
              Time.zone.today.end_of_month
            )
    scope = scope.where(group: groups) if groups.present?
    scope = scope.where(category_id: categories) if categories.present?
    scope.order(date: :desc)
  end
end
