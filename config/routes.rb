Hnrt::Application.routes.draw do |map|
  root :to => "root#index"
  resources :root
end
