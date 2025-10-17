module TransferenceRepository
  module_function

  def all(user_id, limit = 10)
    Transference.where(user_id: user_id)
                .includes(:sender, :receiver)
                .order(date: :desc)
                .limit(limit)
  end

  def create!(attributes)
    Transference.create!(attributes)
  end
end
