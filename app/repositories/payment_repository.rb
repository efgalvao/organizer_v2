class PaymentRepository
  def find_by(attributes)
    Financings::Payment.find_by(attributes)
  end

  def create!(attributes)
    Financings::Payment.create!(attributes)
  end

  def update!(payment, attributes)
    payment.update!(attributes) && payment
  end

  def destroy(payment)
    payment.destroy
  end
end
