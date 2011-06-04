HackerStream::Application.routes.draw do
  root :to => 'root#index'
  resources :item

  resources :user
  resources :story
  resources :my_stream
  resources :following
  resource :active_users
  resource :active_stories

  resource :login
  resources :follow
  resources :unsubscribe

  match 'reply/:id', :to => 'root#reply'
end
