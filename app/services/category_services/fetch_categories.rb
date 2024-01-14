module CategoryServices
  class FetchCategories < ApplicationService
    def self.fetch_categories(user_id)
      Category.where(user_id: user_id).ordered
    end
  end
end
