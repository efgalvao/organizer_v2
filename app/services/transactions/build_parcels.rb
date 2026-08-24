module Transactions
  class BuildParcels
    def initialize(params)
      @params = params
      @parcels = params[:parcels].to_i
      @amount_per_parcel = calculate_amount_per_parcel
      @base_date = (params[:date].presence || Date.current).to_date
      @title = params.fetch(:title)
      @group = params.fetch(:group)
      @type = resolve_transaction_type(params.fetch(:type))
      @recurrence = params.fetch(:recurrence)
      @kind = params.fetch(:kind)

      @account_id = params[:account_id] || resolve_account_id(params[:account])
      @category_id = params[:category_id] || resolve_category_id(params[:category])
    end

    def self.call(params)
      new(params).call
    end

    def call
      return [] if @parcels <= 0

      Array.new(@parcels) { |i| build_transaction(i + 1) }
    end

    private

    attr_reader :params

    def calculate_amount_per_parcel
      return BigDecimal('0') if @parcels <= 0

      BigDecimal(params[:amount].to_s) / @parcels
    end

    def build_transaction(parcel)
      {
        title: title_with_parcel(parcel),
        category_id: @category_id,
        account_id: @account_id,
        type: @type,
        amount: @amount_per_parcel,
        date: (@base_date + (parcel - 1).months).strftime('%Y-%m-%d'),
        group: @group,
        recurrence: @recurrence,
        kind: @kind
      }
    end

    def title_with_parcel(parcel)
      return @title if @parcels == 1

      "#{@title} - #{I18n.t('parcel')} #{parcel}/#{@parcels}"
    end

    def resolve_account_id(account_name)
      return nil if account_name.blank?

      downcased = account_name.to_s.downcase.strip
      AccountRepository.find_by('LOWER(name) = ?', downcased)&.id
    end

    def resolve_category_id(category_name)
      return nil if category_name.blank?

      downcased = category_name.to_s.downcase.strip
      CategoryRepository.find_by('LOWER(name) = ?', downcased)&.id ||
        CategoryRepository.find_by(name: 'Diversos')&.id
    end

    def resolve_transaction_type(type)
      return type if type.to_s.start_with?('Account::')

      case type.to_i
      when 0 then 'Account::Income'
      when 1 then 'Account::Expense'
      when 2 then 'Account::Transference'
      when 3 then 'Account::Investment'
      when 4 then 'Account::InvoicePayment'
      else Account::Transaction
      end
    end
  end
end
