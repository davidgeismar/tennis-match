Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', invitations: 'users/invitations' }

  resource :judge, only: :show
  resources :tournaments, only: [:index, :show, :new, :create] do
    resources :subscriptions, only: [:show, :create, :index, :update]
  end
  post 'tournaments/:tournament_id/convocations/multiple_new', to: "convocations#multiple_new", as: "multiple_new"
  post 'tournaments/:tournament_id/convocation/multiple_create', to: "convocations#multiple_create", as: "multiple_create"

  resources :subscriptions, only: [] do
    resources :convocations, only: [:new, :create]
  end

  # get "tournaments", to: "tournaments#index"

  get "tournaments/:id/invite_player", to: "tournaments#invite_player", as: "invite_player"
  post "tournaments/:id/invite_player", to: "tournaments#invite_player_to_tournament"

  resource :user do
    resources :tournaments, only: [:show, :new, :create, :edit, :update]
  end

  resources :convocations, only: [:edit, :update]



  #get 'tournaments/:tournament_id/subscriptions/profile', to: 'subscriptions#profile', as: 'subscription_profil'
  # get "user/tournaments/:tournament_id/subscription_pending ", to: "subscriptions#pending", as: "subscription_pending"
end
