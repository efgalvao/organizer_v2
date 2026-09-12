module Account
  class Transference < Transaction
    def balance_delta
      outflow? ? -amount.abs : amount.abs
    end
  end
end
