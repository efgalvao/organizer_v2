require 'rails_helper'

RSpec.describe CategoryServices::FetchCategories do
  subject(:fetch_categories) { described_class.fetch_categories(user.id) }

  let(:user) { create(:user) }
  let!(:second_category) { create(:category, name: 'B', user: user) }
  let!(:first_category) { create(:category, name: 'A', user: user) }
  let!(:third_category) { create(:category, name: 'C', user: user) }
  let!(:other_user_category) { create(:category, name: 'D') }

  it 'returns categories ordered by name in ascending order' do
    expect(fetch_categories).to eq([first_category, second_category, third_category])
  end
end
