module UserRepository
  module_function

  def find(id)
    User.find(id)
  end
end
