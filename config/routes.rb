Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Admin
  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resources :pools do
      resources :pool_memberships, only: [:index] do
        member do
          patch :approve
          patch :reject
        end
      end
      resources :matches, only: [:index, :new, :create, :edit, :update, :destroy] do
        collection do
          get :lookup
        end
        member do
          post :sync_result
          get  :bets
        end
      end
    end
    resources :payments, only: [:index, :show] do
      member do
        patch :confirm
        patch :reject
        patch :process_refund
        get   :view_proof
      end
    end
  end

  # Invite flow
  get  "join/:invite_token", to: "pools#invite",  as: :pool_invite
  post "join/:invite_token", to: "pool_memberships#create", as: :pool_join

  # Participant
  resources :pools, only: [:show] do
    resources :matches, only: [:show] do
      resources :bets, only: [:new, :create]
    end
  end
  resources :bets, only: [:index, :show]
  resources :payments, only: [:show] do
    collection do
      post :presigned_url
    end
    member do
      post :submit_proof
      post :request_refund
      get  :view_proof
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index"
end
