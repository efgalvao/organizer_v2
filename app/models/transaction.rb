class Transaction < ApplicationRecord
  self.inheritance_column = :type

  belongs_to :account, touch: true, class_name: 'Account::Account'
  belongs_to :account_report, class_name: 'Account::AccountReport'
  belongs_to :category, optional: true

  delegate :user, :name, to: :account, prefix: 'account'

  enum group: { custos_fixos: 0, conforto: 1, metas: 2, prazeres: 3, liberdade_financeira: 4, conhecimento: 5 }
  enum recurrence: { one_time: 0, recurring: 1, installment: 2 }
  enum kind: { inflow: 0, outflow: 1 }

  scope :ordered, -> { order(date: :desc) }
  scope :future, -> { where('date > ?', Time.zone.today) }
  scope :current_month, -> { where(date: Time.zone.today.beginning_of_month..Time.zone.today) }

  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[account_id category_id group title type]
  end

  def balance_delta
    raise NotImplementedError, "#{self.class.name} deve implementar o método #balance_delta"
  end
end
