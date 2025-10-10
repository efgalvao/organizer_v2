class FinancingRepository
  def all(user_id)
    Financings::Financing.where(user_id: user_id).all
  end

  def create!(attributes)
    Financings::Financing.create!(attributes)
  end

  def update!(financing, attributes)
    financing.update!(attributes)
    financing
  end

  def find_by(attributes = {})
    Financings::Financing.find_by(attributes)
  end

  def payments_for(financing)
    financing.payments.ordered
  end

  def destroy(id)
    Financings::Financing.delete(id)
  end
end
