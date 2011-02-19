Hnrt::Application.routes.draw do |map|
  root :to => "root#index"
  map.connect "/:controller/:action.:format"
end
