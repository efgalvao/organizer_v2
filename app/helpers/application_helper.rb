module ApplicationHelper
  def render_turbo_stream_flash_messages
    turbo_stream.prepend 'flash', partial: 'layouts/flash'
  end

  def form_error_notification(object)
    return unless object.errors.any?

    tag.div class: 'error-message' do
      object.errors.full_messages.to_sentence.capitalize
    end
  end

  def all_accounts(user_id)
    Account::Account.where(user_id: user_id).all.map { |account| [account.name, account.id] }
  end
end
