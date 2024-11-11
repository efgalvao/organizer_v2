module Account
  class Expense < Transaction
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :category_id, presence: true
  end
end
