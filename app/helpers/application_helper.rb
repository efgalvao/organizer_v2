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

  def all_accounts_except_cards(user_id)
    Account::Account.except_cards(user_id).map { |account| [account.name, account.id] }
  end

  def groups_for_select
    Account::Transaction.groups.keys.map { |group| [group.humanize, group] }.to_h
  end

  def user_categories(user_id)
    Category.where(user_id: user_id)
  end
end
