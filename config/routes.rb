Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'      }
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
  end

  # Defines the root path route ("/")
  root 'home#index'

  resources :categories

  scope module: 'account' do
    resources :accounts do
      get :card_accounts, on: :collection
    end  end

  scope module: 'financing' do
    resources :financings do
      resources :payments, except: [:index, :show]
    end
  end
end
