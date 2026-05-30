class TransferenceDecorator < Draper::Decorator
  delegate_all

  def amount
    helpers.format_currency(object.amount)
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
