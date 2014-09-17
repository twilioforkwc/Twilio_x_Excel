Excel::Application.routes.draw do

	get "login", :to => "user_sessions#new"
	post "login", :to => "user_sessions#create"
	delete "logout", :to => "user_sessions#destroy"

  resources :users

  get "app", :to => "app#index"
  resources :call_histories

  post "twilio/stop"
  post "twilio/call"
  post "twilio/ivr/:call_history_id", :to => "twilio#ivr"
  post "twilio/result/:call_history_id", :to => "twilio#result"
  post "twilio/status/:call_history_id", :to => "twilio#status"
  post "twilio/fallback/:call_hsitory_id", :to => "twilio#fallback"

	get "twilio/get_status"

  get "welcome/index"

	post "phone", :to => "user_apps#phone"
	post "my_app", :to => "user_apps#appinfo"
	get "my_app/:pin", :to => "user_apps#token"
  resources :user_apps

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
