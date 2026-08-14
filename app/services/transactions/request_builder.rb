module Transactions
  class RequestBuilder
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      ActiveRecord::Base.transaction do
        saved_transactions = Transactions::BuildParcels.call(build_transaction).map do |transaction|
          Transactions::ProcessRequest.call(
            params: transaction,
            # value_to_update_balance: balance_delta_for(transaction),
            raise_on_error: true
          )
        end

        apply_balance_updates(saved_transactions)
        consolidate_reports(saved_transactions)

        saved_transactions.first
      end
    rescue StandardError => e
      error_response(e.message)
    end

    private

    attr_reader :params

    def build_transaction
      {
        title: params.fetch(:title),
        category_id: params[:category_id],
        account_id: params.fetch(:account_id),
        type: params.fetch(:type),
        amount: params.fetch(:amount),
        date: date,
        parcels: params[:parcels],
        group: params.fetch(:group),
        recurrence: params.fetch(:recurrence)
      }
    end

    def apply_balance_updates(transactions)
      transactions.group_by(&:account_id).each do |account_id, account_transactions|
        total = account_transactions.sum { |transaction| balance_delta_for(transaction) }
        next if total.zero?

        Accounts::UpdateBalance.call(account_id: account_id, amount: total)
      end
    end

    def consolidate_reports(transactions)
      transactions.group_by { |transaction| [transaction.account_id, transaction.date.beginning_of_month] }
                  .each_value do |month_transactions|
        transaction = month_transactions.first
        Reports::ConsolidateAccountReport.call(transaction.account, transaction.date)
      end
    end

    def balance_delta_for(transaction)
      type = fetch_attribute(transaction, :type)
      amount = fetch_attribute(transaction, :amount).to_d

      type == 'Account::Expense' ? -amount : amount
    end

    def error_response(message)
      transaction = Account::Transaction.new
      transaction.errors.add(:base, message)
      transaction
    end

    def date
      params[:date].presence || Date.current.strftime('%Y-%m-%d')
    end

    def fetch_attribute(object, key)
      object.respond_to?(key) ? object.public_send(key) : object[key]
    end
  end
end
