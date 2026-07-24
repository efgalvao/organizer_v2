
class TargetRepository
  def initialize(user)
    @user = user
  end

  def find_all_indexed_by_kind
    @user.asset_class_targets.index_by(&:kind)
  end

  def upsert_targets!(targets_hash)
    ActiveRecord::Base.transaction do
      targets_hash.each do |kind, percentage|
        target = @user.asset_class_targets.find_or_initialize_by(kind: kind)
        target.update!(target_percentage: percentage)
      end
    end
  end
end
