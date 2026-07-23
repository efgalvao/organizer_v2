require 'rails_helper'

RSpec.describe 'Portfolio::Targets' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /portfolio/targets' do
    it 'returns a success response' do
      get portfolio_targets_path

      expect(response).to be_successful
    end

    it 'includes asset class labels in the form' do
      create(:asset_class_target, user: user, kind: :fixed, target_percentage: 25.0)

      get portfolio_targets_path

      expect(response.body).to include(
        I18n.t('activerecord.attributes.investments/investment.kinds.fixed')
      )
    end
  end

  describe 'POST /portfolio/targets' do
    context 'when the total percentage is 100' do
      it 'creates or updates targets and redirects to allocations' do
        expect do
          post portfolio_targets_path, params: {
            targets: {
              fixed: 40,
              stock: 60
            }
          }
        end.to change { user.asset_class_targets.count }.by(2)

        expect(user.asset_class_targets.find_by(kind: :fixed).target_percentage).to eq(40.0)
        expect(user.asset_class_targets.find_by(kind: :stock).target_percentage).to eq(60.0)
        expect(response).to redirect_to(portfolio_allocations_path)
      end

      it 'updates existing targets' do
        create(:asset_class_target, user: user, kind: :fixed, target_percentage: 10.0)

        post portfolio_targets_path, params: {
          targets: {
            fixed: 100
          }
        }

        expect(user.asset_class_targets.find_by(kind: :fixed).target_percentage).to eq(100.0)
        expect(response).to redirect_to(portfolio_allocations_path)
      end
    end

    context 'when the total percentage is not 100' do
      it 'does not persist targets and returns unprocessable entity' do
        expect do
          post portfolio_targets_path, params: {
            targets: {
              fixed: 50,
              stock: 40
            }
          }
        end.not_to change(AssetClassTarget, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
