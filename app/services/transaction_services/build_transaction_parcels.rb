module TransactionServices
  class BuildTransactionParcels
    def initialize(params)
      @params = params
    end

    def self.call(params)
      new(params).call
    end

    def call
      (1..params[:parcels].to_i).map { |parcel| build_transaction(params, parcel) }
    end

    private

    attr_reader :params

    def build_transaction(params, parcel)
      {
        title: title(params.fetch(:title), parcel, params[:parcels]),
        category_id: category_id(params.fetch(:category)),
        account_id: account_id(params.fetch(:account)),
        kind: params.fetch(:kind),
        value: params.fetch(:value).to_f / params[:parcels].to_i,
        date: calculate_date(params[:date], parcel)
      }
    end

    def title(title, parcel, total_parcels)
      total_parcels.to_i > 1 ? title + " - #{I18n.t('parcel')} #{parcel}/#{total_parcels}" : title
    end

    def account_id(account_name)
      downcased_name = account_name.downcase.strip
      Account::Account.find_by('LOWER(name) = ?', downcased_name)&.id
    end

    def category_id(category_name)
      return nil if category_name.blank?

      downcased_name = category_name.downcase.strip
      Category.find_by('LOWER(name) = ?', downcased_name)&.id.presence || Category.find_by(name: 'Diversos')&.id
    end

    def calculate_date(date, parcel)
      (Date.parse(date) + (parcel - 1).months).strftime('%Y-%m-%d')
    end
  end
end
