Rails.application.routes.draw do
  resources :traces, only: [:index, :show]
end
