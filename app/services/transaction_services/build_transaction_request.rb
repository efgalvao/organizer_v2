module TransactionServices
  class BuildTransactionRequest < ApplicationService
    def initialize(transaction_string)
      @transaction_string = transaction_string
      @date = set_date
    end

    def self.call(transaction_string)
      new(transaction_string).call
    end

    def call
      return [params] if params[:parcels].to_i == 1

      ActiveRecord::Base.transaction do
        (1..params[:parcels].to_i).map do |parcel|
          build_transaction(parcel)
        end
      end
      transactions
    end

    private

    attr_reader :transaction_string, :parcels

    def params
      @params ||= keys = %i[account kind title category value date parcels]
      values = transaction_string.split(',')
      keys.zip(values).to_h
    end

    def build_transaction(parcel)
      {
        title: params.fetch(:title) + " - #{I18n.t('parcel')} #{parcel}/#{params[:parcels]}",
        category_id: params.fetch(:category_id),
        account_id: params.fetch(:account_id),
        kind: params.fetch(:kind),
        value: params.fetch(:value).to_f / params[:parcels].to_i,
        date: Date.parse(date) + (parcel - 1).months
      }
    end

    def process_transaction(transaction)
      TransactionServices::ProcessTransactionRequest.call(transaction)
    end

    def set_date
      return Date.current if params.fetch(:date) == ''

      params.fetch(:date)
    end
  end
end
