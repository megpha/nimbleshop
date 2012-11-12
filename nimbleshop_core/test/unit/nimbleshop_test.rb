require 'test_helper'

class NimbleshopTest < ActiveSupport::TestCase

  test "#theme_class accepts engine kind class" do
    Nimbleshop.theme_class = NimbleshopSimply

    assert_equal NimbleshopSimply::Engine, Nimbleshop.theme_engine
  end

  test "#theme_class wont accept non engine kind class" do
   method = -> { 
     begin
      Nimbleshop.theme_class = String 
      'passed'
     rescue
       'failed' 
     end
   }

   assert_equal 'failed', method.()
  end

  test "#route_segment can be overriden" do
   Nimbleshop.root_route = 'products#index'

   assert_equal 'products#index', Nimbleshop.root_route_segment
   Nimbleshop.root_route = nil
  end

  test "#route_segment has default root" do
   assert_equal 'nimbleshop_simply/products#index', Nimbleshop.root_route_segment
  end
end
