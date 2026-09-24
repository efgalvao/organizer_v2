class Transaction::Expense < Transaction
  validates :group, presence: true

  def balance_delta
    -amount.abs
  end
end
