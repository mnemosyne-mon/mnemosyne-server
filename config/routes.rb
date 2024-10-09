# frozen_string_literal: true

Rails.application.routes.draw do
  get "/t", to: "root#trace", as: "search"
  get "/t/:id", to: "root#trace", as: "t"
  get "/platform/:id", to: "platforms#show", as: "platform"

  scope path: "/platform/:platform" do
    resources :traces, only: %i[index show update]
    resources :spans, only: %i[show]
    resources :applications, only: %i[index]
    resources :failures, only: %i[index show]
  end

  root to: "platforms#index"
end
