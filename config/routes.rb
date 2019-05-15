Rails.application.routes.draw do
  resources :urls, only: [:create, :update]
  get '/:slug', to: 'urls#show'
  root to: "urls#index"
end
