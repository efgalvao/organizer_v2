class UserDecorator < Draper::Decorator
  delegate_all

  def investment_kinds
    Investments::Investment.kinds.keys
  end

  def target_percentage_for(kind_key)
    existing_targets[kind_key]&.target_percentage || 0.0
  end

  def label_for(kind_key)
    h.t(
      "activerecord.attributes.investments/investment.kinds.#{kind_key}",
      default: kind_key.humanize
    )
  end

  private

  def repository
    @repository ||= context[:repository] || Portfolio::TargetRepository.new(object)
  end

  def existing_targets
    @existing_targets ||= repository.find_all_indexed_by_kind
  end
end
