Members::Application.routes.draw do
  resources :member_sessions

  resources :members do
    collection do
      get :list
    end
  end

  resources :topics do
    member do
      get :enthusiasts
      get :experts
      get :speakers
      get :auto_complete_for_topic_name
    end
    resources :interests
  end

  resources :password_resets
  match '/' => 'members#index'
  match '/login' => 'member_sessions#new', :as => :login
  match '/logout' => 'member_sessions#destroy', :as => :logout
end
