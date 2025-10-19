module CategoryRepository
  module_function

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

  def destroy(id)
    Category.delete(id)
  end
end
