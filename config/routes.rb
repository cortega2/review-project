Rails.application.routes.draw do
  resources :reviews, :only => [:index, :show] do
    resources :review_items, :only => [:index, :show]
  end

  resources :jobs, :only => [:index, :create, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#index'
end
