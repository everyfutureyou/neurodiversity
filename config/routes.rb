Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root redirect → detected/default locale
  get "/", to: "home#redirect_to_locale"

  # Locale-scoped routes — locale is part of every URL; default_url_options injects it automatically.
  # Parentheses make locale optional so tests and edge-cases don't need to provide it explicitly,
  # but ApplicationController#default_url_options always emits locale-prefixed URLs in production.
  scope "(:locale)", locale: /de|en/, defaults: { locale: "en" } do
    root "home#index"

    # Authentication
    resource :session, only: %i[new create destroy]
    resources :registrations, only: %i[new create] do
      collection do
        get :confirm
      end
    end
    resources :passwords, param: :token, only: %i[new create edit update]
  end

  # Dev-only component gallery
  if Rails.env.development?
    namespace :dev do
      get "components", to: "components#index"
    end
  end
end
