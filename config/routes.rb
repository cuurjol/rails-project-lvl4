# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: :web do
    mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
    root 'home#index'

    resources :repositories, only: %i[index new create show destroy] do
      scope module: :repositories do
        resources :checks, only: %i[create show]
      end

      patch :update_from_github, on: :member
    end

    get 'auth/:provider/callback', to: 'auth#callback', as: :callback_auth
    post 'auth/:provider', to: 'auth#request', as: :auth_request
    delete 'auth/sign_out', to: 'auth#destroy', as: :sign_out
  end

  namespace :api do
    resources :checks, only: :create
  end
end
