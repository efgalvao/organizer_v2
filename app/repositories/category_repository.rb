class CategoryRepository
  def all(user_id)
    Category.where(user_id: user_id).order(:name)
  end

  def create!(attributes)
    Category.create!(attributes)
  end

  def update!(category, attributes)
    category.update!(attributes)
    category
  end

  def find(id)
    Category.find(id)
  end

  def find_by(attributes = {})
    Category.find_by(attributes)
  end

  def destroy(id)
    Category.delete(id)
  end

  def by_user(user_id)
    Category.where(user_id: user_id)
  end
end
