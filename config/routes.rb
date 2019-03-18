Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
  get '/login', to: 'sessions#new'
  get '/products/delete_image/:id', to: 'products#delete_image'
  resources :products
  resources :sessions
  put '/products', to: 'products#update'
  get '/searches/:search', to: 'searches#show'
  resources :price_csvs, :path => 'update_prices', controller: "update_prices"
  get "/help", to: 'help#index'
  resources :searches, :homerica, :categories, :missing_items, :price_csv, :bulk_create_product, :images, :scrape_missing_items
end
