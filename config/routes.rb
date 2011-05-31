Hnrt::Application.routes.draw do
  root :to => 'root#index'
  resources :item

  resources :user
  resources :story
  resources :following
  resource :active_users
  resource :active_stories

  resource :login
  resources :follow

  match 'reply/:id', :to => 'root#reply'
end
