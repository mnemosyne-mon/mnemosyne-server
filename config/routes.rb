# frozen_string_literal: true

Rails.application.routes.draw do
  resources :platforms, only: %i(show), path: 'platform' do
    get 'traces', to: 'traces#index'
    get 'trace/:id', to: 'traces#show', as: 'trace'
  end

  root to: 'platforms#index'
end
