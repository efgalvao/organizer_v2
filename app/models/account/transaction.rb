module Account
  class Transaction < ApplicationRecord
    belongs_to :account, touch: true
    belongs_to :account_report, class_name: 'Account::AccountReport'
    has_one :category, class_name: 'Category', foreign_key: 'id', primary_key: 'category_id', dependent: nil

    validates :title, presence: true

    enum group: { custos_fixos: 0, conforto: 1, metas: 2, prazeres: 3, liberdade_financeira: 4, conhecimento: 5 }

    delegate :user, :name, to: :account, prefix: 'account'

    self.inheritance_column = :type

    def self.types
      %w[Account::Income Account::Expense Account::Transference Account::Investment Account::InvoicePayment]
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w[account category_id group title type]
    end
  end
end
