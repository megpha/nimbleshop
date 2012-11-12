module Nimbleshop
  mattr_accessor :root_route

  @@theme_class = nil

  def self.theme_class=(klass)
    if klass.const_defined?('Engine')
      engine_klass = klass.const_get('Engine') 
    else
      raise "could not find Engine class"
    end

    unless engine_klass || engine_klass.is_a?(::Rails::Engine)
      raise 'only engines can be theme classes'
    end

    @@theme_class = klass
  end

  def self.theme_class
    @@theme_class || NimbleshopSimply
  end

  def self.theme_engine
    theme_class.const_get('Engine')
  end

  def self.root_route_segment
    @@root_route || "#{theme_class.to_s.underscore}/products#index"
  end

  class Engine < ::Rails::Engine

    engine_name 'nimbleshop_core'

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/nimbleshop)

    initializer 'nimbleshop_core.config_to_prepare' do |app|
      app.config.to_prepare do
        Address
        ShippingZone
      end
    end

    initializer 'nimbleshop_core.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper AdminHelper
        helper NimbleshopHelper
        helper PaymentMethodHelper
      end
    end
  end
end
