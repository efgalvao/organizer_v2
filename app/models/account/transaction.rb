module Account
  class Transaction < ApplicationRecord
    belongs_to :account, touch: true
    belongs_to :account_report, class_name: 'Account::AccountReport'
    has_one :category, class_name: 'Category', foreign_key: 'id', primary_key: 'category_id', dependent: nil

    validates :title, presence: true

    enum group: { custos_fixos: 0, conforto: 1, metas: 2, prazeres: 3, liberdade_financeira: 4, conhecimento: 5 }

    delegate :user, :name, to: :account, prefix: 'account'

    self.inheritance_column = :type
  end

  class Income < Transaction
    validates :source, presence: true
  end

  class Expense < Transaction
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :category_id, presence: true
  end

  class Transference < Transaction
    belongs_to :sender, class_name: 'Account::Account'
    belongs_to :receiver, class_name: 'Account::Account'
    belongs_to :user

    validates :date, :amount, presence: true
    validate :different_accounts

    def different_accounts
      errors.add(:base, 'Accounts must be different') if sender_id == receiver_id
    end
  end

  class Investment < Transaction
    # Remove `kind` attribute and validations
  end

  class Invoice < Transaction
    # Add validations for Invoice specific attributes
  end
end
