module FinancingServices
  class CreateFinancing
    def initialize(params)
      @user_id = params[:user_id]
      @borrowed_value = params[:borrowed_value]
      @installments = params[:installments]
      @name = params[:name]
    end

    def self.call(params)
      new(params).call
    end

    def call
      financing = Financings::Financing.new(financing_attributes)
      financing.save
      financing
    end

    private

    attr_reader :user_id, :borrowed_value, :installments, :name

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
