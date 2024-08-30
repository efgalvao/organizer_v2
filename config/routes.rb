Rails.application.routes.draw do
  devise_for :users
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
      member do
        get 'consolidate_report', to: 'accounts#consolidate_report', as: 'consolidate_report'
      end
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

  get '/file_upload', to: 'files#file_upload'
  post '/upload', to: 'files#upload'
end
