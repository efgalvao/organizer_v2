module Account
  class Income < Transaction
    validates :source, presence: true
  end
end
