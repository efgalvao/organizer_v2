module TransactionServices
  class FetchTransactions
    def initialize(params, user_id)
      @groups = params[:groups]
      @categories = params[:categories]
      @user_id = user_id
    end

    def self.call(params, user_id)
      new(params, user_id).call
    end

    def call
      fetch_transactions
    rescue StandardError
      []
    end

    private

    attr_reader :groups, :categories, :user_id

    def fetch_transactions
      execute_query(
        fetch_transactions_sql,
        'fetch_transactions',
        {
          user_id: user_id,
          groups: groups,
          categories: categories,
          start_date: Time.zone.today.beginning_of_month,
          end_date: Time.zone.today.end_of_month
        }
      ).to_a
    end

    def fetch_transactions_sql
      <<~SQL.squish.strip
        SELECT *
        FROM transactions
        INNER JOIN accounts ON accounts.id = transactions.account_id
        LEFT JOIN categories ON categories.id = transactions.category_id
        WHERE accounts.user_id = :user_id
        AND date >= :start_date AND date <= :end_date
        #{groups_presents}
        #{categories_present}
        ORDER BY date DESC
      SQL
    end

    def groups_presents
      groups.present? ? 'AND transactions.group IN (:groups)' : ''
    end

    def categories_present
      categories.present? ? 'AND transactions.category_id IN (:categories)' : ''
    end

    def execute_query(query, identifier, params)
      ApplicationRecord.connection.exec_query(
        ApplicationRecord.sanitize_sql_array([query, params]),
        identifier
      )
    end
  end
end
