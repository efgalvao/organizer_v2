module FinancingServices
  class CreatePayment
    def initialize(params)
      @params = params
      @payment_repository = PaymentRepository.new
    end

    def self.call(params)
      new(params).call
    end

    def call
      payment_repository.create!(payment_attributes)
    rescue StandardError
      Financings::Payment.new
    end

    private

    attr_reader :params, :payment_repository

    def payment_attributes
      {
        financing_id: params[:financing_id],
        parcel: ordinary? ? next_ordinary_parcel : 0,
        paid_parcels: params[:paid_parcels],
        ordinary: params[:ordinary],
        payment_date: set_date,
        amortization: value_to_decimal(params[:amortization]),
        fees: value_to_decimal(params[:fees]),
        interest: value_to_decimal(params[:interest]),
        insurance: value_to_decimal(params[:insurance]),
        adjustment: value_to_decimal(params[:adjustment]),
        monetary_correction: value_to_decimal(params[:monetary_correction])
      }
    end

    def value_to_decimal(value)
      return 0 if value.nil?

      value.to_d
    end

    def financing
      @financing ||= FinancingRepository.new.find_by({ id: params[:financing_id] })
    end

    def next_ordinary_parcel
      financing.payments.ordered.ordinary.first&.parcel.to_i + 1
    end

    def ordinary?
      params[:ordinary] == 'true'
    end

    def set_date
      params[:payment_date].presence || Time.zone.today.strftime('%Y-%m-%d')
    end
  end
end
