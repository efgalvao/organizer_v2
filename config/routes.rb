Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'      }
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
  end

  # Defines the root path route ("/")
  root 'home#index'
  get 'summary', to: 'home#show', as: 'summary'


  resources :categories
  resources :transferences, only: %i[index new create]

  resources :cards do
    resource 'invoice', on: :member, only: %i[new create]
  end

  scope module: 'account' do
    resources :accounts do

      resources :transactions, only: %i[index new create edit update]
    end
  end

  scope module: 'financing' do
    resources :financings do
      resources :payments, except: [:index, :show]
    end
  end

  scope module: 'investments' do

    resources :investments, except: [:destroy, :new] do
      resources :negotiations, only: [:index, :new, :create]
      resources :positions, only: [:index, :new, :create]
      resources :dividends, only: [:index, :new, :create]
    end
    get '/investments/:account_id/new', to: 'investments#new', as: 'new_investment'

  end
end
