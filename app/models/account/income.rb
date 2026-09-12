module Account
  class Income < Transaction
    def balance_delta
      amount.abs
    end
  end
end
