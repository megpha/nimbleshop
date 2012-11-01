Rails.application.routes.draw do

  root to: 'nimbleshop_simply/products#index'

  get '/admin',           to: 'admin/main#index'

  # Ideally it should only be included in development mode
  get "/reset",           to: "admin/main#reset"

  namespace :admin do

    resource  :shop,            only: [:update, :edit]

    resource  :payment_gateway
    resources :payment_methods do
      member do
        put :enable
        put :disable
      end
    end

    resources :products,        except: [:show]
    resources :product_groups
    resources :custom_fields

    resources :orders do
      resources :shipments,      except: [:edit, :update]
      member do
        put :capture_payment
        put :purchase_payment
      end
    end

    resources :country_shipping_zones, controller: :shipping_zones do
      resources :shipping_methods
    end

    resources :regional_shipping_zones, controller: :shipping_zones do
      resources :shipping_methods do
        member do
          put :update_offset
          put :disable
          put :enable
        end
      end
    end

    resources :shipping_zones do
      resources :shipping_methods
    end

    resources :link_groups do
      resources :navigations, only: [:create, :new, :destroy]
    end

  end

  mount NimbleshopAuthorizedotnet::Engine, at: '/nimbleshop_authorizedotnet'
  mount NimbleshopPaypalwp::Engine,        at: '/nimbleshop_paypalwp'
  mount NimbleshopSplitable::Engine,       at: '/nimbleshop_splitable'
  mount NimbleshopCod::Engine,             at: '/nimbleshop_cod'
  mount NimbleshopSimply::Engine,          at: '/'

end
