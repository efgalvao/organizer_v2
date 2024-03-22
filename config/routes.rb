Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'      }
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
  end

  # Defines the root path route ("/")
  root 'home#index'

  resources :categories
  resources :transferences, only: %i[index new create]

  resources :cards

  scope module: 'account' do
    resources :accounts do

      resources :transactions, only: %i[index new create edit update]
    end  end

  scope module: 'financing' do
    resources :financings do
      resources :payments, except: [:index, :show]
    end
  end
end
