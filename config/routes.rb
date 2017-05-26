# frozen_string_literal: true

Rails.application.routes.draw do
  resources :platforms, only: %i[show], path: 'platform' do
    get 'traces', to: 'traces#index'
    get 'traces/heatmap', to: 'traces#heatmap'
    get 'trace/:id', to: 'traces#show', as: 'trace'

    get 'errors', to: 'errors#index'
  end

  root to: 'platforms#index'
end
