class Transaction::Income < Transaction
  def balance_delta
    amount.abs
  end
end
