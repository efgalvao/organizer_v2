module CategoryServices
  class FetchCategories < ApplicationService
    def self.fetch_categories(user_id)
      CategoryRepository.new.all(user_id)
    end
  end
end
