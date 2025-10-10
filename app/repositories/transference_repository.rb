class TransferenceRepository
  def all(user_id, limit = 10)
    Transference.where(user_id: user_id)
                .includes(:sender, :receiver)
                .order(date: :desc)
                .limit(limit)
  end

  def create!(attributes)
    Transference.create!(attributes)
  end

  def update!(transference, attributes)
    transference.update!(attributes)
    transference
  end

  def find(id)
    Transference.find(id)
  end

  def find_by(attributes = {})
    Transference.find_by(attributes)
  end

  def destroy(id)
    Transference.delete(id)
  end

  def by_user(user_id)
    Transference.where(user_id: user_id)
  end
end
