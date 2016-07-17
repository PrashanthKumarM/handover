Rails.application.routes.draw do
 
#get 'profile/index', as: :profiles

get 'settings/index', as: :settings
get 'view_trees/index', as: :tree
resources :uploads, only: [:index, :new, :create, :destroy]     
resources :password_resets, only: [:new, :create, :edit, :update]
resources :users, only: [:new, :create, :edit]
resources :user_sessions, only: [:create, :destroy]
resources :decision_trees, only: [:index] do
  member do
    get :list_priorities
  end
end
delete '/sign_out', to: 'user_sessions#destroy', as: :sign_out
get '/sign_in', to: 'user_sessions#new', as: :sign_in
post '/escalate/:token', to: 'decision_trees#escalate', as: :escalate

#get 'page/index'
 #root "uploads#index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
#root 'page#index'
  # You can have the root of your site routed with "root"
root 'page#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
