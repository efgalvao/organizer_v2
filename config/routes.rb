Rails.application.routes.draw do
  mount Coverband::Reporters::Web.new, at: '/coverage'

  devise_for :users
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
  end

  root 'home#index'
  get 'summary', to: 'home#show', as: 'summary'
  get 'transactions', to: 'home#transactions', as: 'transactions'

  resources :categories, except: %i[show]
  resources :transferences, only: %i[index new create]

  resources :cards do
    resource 'invoice', on: :member, only: %i[new create]
  end

  scope module: 'account' do
    resources :accounts do
      member do
        get 'consolidate_report', to: 'accounts#consolidate_report', as: 'consolidate_report'
      end
      resources :transactions, only: %i[index new create edit update] do
        member do
          get 'anticipate_form', to: 'transactions#anticipate_form', as: 'anticipate_form'
          post 'anticipate', to: 'transactions#anticipate', as: 'anticipate'
        end
      end
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
      resources :interest_on_equities, only: [:index, :new, :create]
      get :update_quote, on: :member
    end
    get '/investments/:account_id/new', to: 'investments#new', as: 'new_investment'
  end
end
