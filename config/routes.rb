Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'      }
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
  end

  # Defines the root path route ("/")
  root 'home#index'

  resources :categories

  scope module: 'financing' do
    resources :installments, except: [:show]
    resources :financings do
    end
  end
end
