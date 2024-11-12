module Account
  class Expense < Transaction
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :group, presence: true
  end
end
