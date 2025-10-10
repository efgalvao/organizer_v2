module FinancingServices
  class CreateFinancing
    def initialize(params)
      @user_id = params[:user_id]
      @borrowed_value = params[:borrowed_value]
      @installments = params[:installments]
      @name = params[:name]
      @financing_repository = FinancingRepository.new
    end

    def self.call(params)
      new(params).call
    end

    def call
      financing_repository.create!(financing_attributes)
    rescue StandardError
      Financings::Financing.new
    end

    private

    attr_reader :user_id, :borrowed_value, :installments, :name, :financing_repository

    def financing_attributes
      {
        name: name,
        user_id: user_id,
        borrowed_value: value_to_decimal(borrowed_value),
        installments: installments
      }
    end

    def value_to_decimal(value)
      value.to_d
    end
  end
end
