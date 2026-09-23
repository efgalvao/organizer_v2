class Transaction::Redeem < Transaction
  def balance_delta
    amount.abs
  end
end
