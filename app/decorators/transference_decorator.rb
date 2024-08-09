class TransferenceDecorator < Draper::Decorator
  delegate_all

  def amount
    ActionController::Base.helpers.number_to_currency(object.amount, unit: 'R$ ', separator: ',', delimiter: '.')
  end

  def date
    object.date.strftime('%d/%m/%Y')
  end

  def sender
    object.sender.name.capitalize
  end

  def receiver
    object.receiver.name.capitalize
  end

  delegate :sender_id, to: :object

  delegate :receiver_id, to: :object
end
