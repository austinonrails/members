Members::Application.routes.draw do
  resources :password_resets, only: [:create, :update]
  resources :member_sessions, only: [:new, :create, :destroy]

  resources :members do
    collection do
      get :list
      get :search
    end
  end

  resources :topics do
    collection do
      get :search
    end
    member do
      get :enthusiasts
      get :experts
      get :speakers
      get :auto_complete_for_topic_name
    end
    resources :interests
  end

  match '/login' => 'member_sessions#new', :as => :login
  match '/logout' => 'member_sessions#destroy', :as => :logout
  root to: 'members#index'
end
