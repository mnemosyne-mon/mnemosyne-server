# frozen_string_literal: true

Rails.application.routes.draw do
  get '/platform/:id', to: 'platforms#show', as: 'platform'

  scope path: '/platform/:platform' do
    get 'traces/heatmap', to: 'traces#heatmap', as: 'heatmap'

    resources :traces, only: %i[index show]
    resources :spans, only: %i[show]
    resources :applications, only: %i[index]
    resources :errors, only: %i[index]
  end

  root to: 'platforms#index'
end
