Hnrt::Application.routes.draw do
  root :to => 'root#index'
  resources :item
  resources :user
end
