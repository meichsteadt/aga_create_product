Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
  get '/login', to: 'sessions#new'
  get '/products/delete_image/:id', to: 'products#delete_image'
  resources :products
  resources :sessions
  put '/products', to: 'products#update'
  get '/searches/:search', to: 'searches#show'
  resources :searches, :homerica, :categories
end
