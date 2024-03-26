Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  
  root "posts#index"
  resources :posts

  delete "sessions_destroy", to: "sessions#destroy" , as: "remove_user_session"
 # delete "products/remove_from_cart/:id", to: "products#remove_from_cart", as: "remove_from_cart"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
