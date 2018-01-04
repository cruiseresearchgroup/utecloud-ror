Rails.application.routes.draw do
  resources :ute_experiments

  get 'users/passwordchange_byadmin' => "users#admin_password_change", :as => "admin_password_change"
  post "users/admin_update_password" => "users#admin_update_password", :as => "admin_update_password"

  get 'users/login'
  get 'users/logout'
  get "sign_up" => "users#new", :as => "sign_up"
  post "login_authenticate" => "users#login_authenticate", :as => "login_authenticate"

  resources :users

  get 'portal/sessionconnectioninfos'
  get 'portal/experimentlist'

  get 'portal/sensorInfos'

  get 'portal/index'

  get 'portal/connections'

  get 'portal/sessionlist'

  get 'inspections/show_aggregations'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'portal#index'

   #portal actions

   get 'portal/experiment/new' => 'portal#newexperiment'
   post 'portal/experiment/createnew' => 'portal#createnewexperiment'
   get 'portal/experiment/edit/:id' => 'portal#editexperiment'
   post 'portal/experiment/update/:id' => 'portal#updateexperiment'
   post 'portal/experiment/remove' => 'portal#removeexperiment'
   post 'portal/experiment/purge' => 'portal#purgeexperimentdata'
   get 'portal/experiment/:id/sessionconnectionlist' => 'portal#sessionconnectionlist'
   post 'portal/experiment/createnewdevicepair' => 'portal#createnewdevicepair'
   #get 'portal/experiment/:id/paired/device/list' => 'portal#paireddeviceslist'
   post 'portal/experiment/removepaireddevices' => 'portal#removepaireddevices'
   get 'portal/experiment/:id/csv/:sessionId/sensorinfos/:connectionId' => 'portal#sensorInfos'
   get 'portal/experiment/:id/csv/:sessionId/bluetoothinfos/:connectionId' => 'portal#bluetoothInfos'
   get 'portal/experiment/:id/csv/:sessionId/wifiinfos/:connectionId' => 'portal#wifiInfos'
   get 'portal/experiment/:id/csv/:sessionId/cellinfos/:connectionId' => 'portal#cellInfos'
   get 'portal/experiment/:id/csv/:sessionId/intervallabels/:connectionId' => 'portal#intervalLabels'

   #api
   match 'api/genudid' => 'ute_api#generateDeviceUuid', via: [:get, :post]
   match 'api/experiment/list' => 'ute_api#experimentList', via: [:get, :post]
   match 'api/experiment/details' => 'ute_api#getExperimentDetails', via: [:get, :post]
   match 'api/experiment/session/create' => 'ute_api#createSession', via: [:get, :post]
   match 'api/session/list' => 'ute_api#sessionList', via: [:get, :post]
   match 'api/experiment/session/connect' => 'ute_api#connectSession', via: [:get, :post]
   match 'api/experiment/session/sensors/submit' => 'ute_api#submitSessionInfos', via: [:post]
   match 'api/experiment/session/bluetooths/submit' => 'ute_api#submitSessionBluetooths', via: [:post]
   match 'api/experiment/session/wifis/submit' => 'ute_api#submitSessionWifis', via: [:post]
   match 'api/experiment/session/cells/submit' => 'ute_api#submitSessionCells', via: [:post]
   match 'api/experiment/session/labels/submit' => 'ute_api#submitSessionLabels', via: [:post]
   match 'api/experiment/session/connection/close' => 'ute_api#closeSessionConnection', via: [:post]
   match 'api/experiment/pairdevice' => 'ute_api#pairDevice', via: [:post]
   match 'api/experiment/unpairdevice' => 'ute_api#unpairDevice', via: [:post]
   
   # Pending routes to be implemented (under consideration)
   get 'inspections' => 'inspections#index'
   get 'inspections/index'
   get 'inspections/session/:id' => 'inspections#connections'
   get 'inspections/session/sensor/info/:connectionId' => 'inspections#sensorInfos'
   get 'inspections/session/survey/info/:connectionId' => 'inspections#surveys'
   get 'inspections/session/:id/show_aggregations' => 'inspections#show_aggregations'
   post 'inspections/session/aggregate' => 'inspections#aggregate_service_survey'
   get 'inspections/session/viz/highcharts/sensor/info/singular' => 'inspections#get_time_series_sensor'
   get '/inspections/session/viz/highcharts/sensor/survey/aggregate' => 'inspections#get_time_series_aggregated_label'
   
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
