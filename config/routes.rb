Hnrt::Application.routes.draw do
  root :to => 'root#index'
  resources :item
  resources :user
  resources :story
  resource :active_users
  resource :active_stories
end
