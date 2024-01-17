module FinancingServices
  class UpdateFinancing
    def initialize(financing_id, params)
      @user_id = params[:user_id]
      @borrowed_value = params[:borrowed_value_cents]
      @installments = params[:installments]
      @name = params[:name]
      @financing_id = financing_id
    end

    def self.call(financing_id, params)
      new(financing_id, params).call
    end

    def call
      update_financing
    end

    private

    attr_reader :user_id, :borrowed_value, :installments, :name, :financing_id

    def financing
      @financing ||= Financings::Financing.find_by(id: financing_id, user_id: user_id)
    end

    def update_financing
      financing.update(financing_attributes)
      financing
    end

    def financing_attributes
      {
        name: new_name,
        borrowed_value_cents: new_borrowed_value,
        installments: new_installments
      }
    end

    def new_name
      name.nil? ? financing.name : name
    end

    def new_borrowed_value
      borrowed_value.nil? ? financing.borrowed_value_cents : value_to_cents(borrowed_value)
    end

    def new_installments
      installments.nil? ? financing.installments : installments
    end

    def value_to_cents(value)
      value.to_f * 100
    end
  end
end
