
  class Transaction::Investment < Transaction
    def balance_delta
      outflow? ? -amount.abs : amount.abs
    end
  end
