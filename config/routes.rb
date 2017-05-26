# frozen_string_literal: true

Rails.application.routes.draw do

  get '/platform/:id', to: 'platforms#show', as: 'platform'

  scope path: '/platform/:platform' do
    get 'traces', to: 'traces#index'
    get 'traces/heatmap', to: 'traces#heatmap', as: 'heatmap'
    get 'trace/:id', to: 'traces#show', as: 'trace'
    get 'span/:id', to: 'spans#show', as: 'span'

    get 'errors', to: 'errors#index'
  end

  root to: 'platforms#index'
end
