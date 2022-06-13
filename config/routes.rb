# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: :web do
    root 'home#index'

    get 'auth/:provider/callback', to: 'auth#callback', as: :callback_auth
    post 'auth/:provider', to: 'auth#request', as: :auth_request
    delete 'auth/sign_out', to: 'auth#destroy', as: :sign_out
  end
end
