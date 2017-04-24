# frozen_string_literal: true

Rails.application.routes.draw do
  resources :traces, only: %i[index show]
  resources :transactions, only: %i[index show]

  root to: 'root#index'
end
