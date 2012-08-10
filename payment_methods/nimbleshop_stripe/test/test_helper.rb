require 'bundler'
Bundler.setup(:test)

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../../../nimbleshop_core/test/myshop/config/environment.rb",  __FILE__)
require 'rails/test_help'
require 'active_record/fixtures'

require 'factory_girl'
Dir["#{File.dirname(__FILE__)}/../../../nimbleshop_core/test/factories/**"].each { |f| require File.expand_path(f) }

VCR.configure do | c |
  c.ignore_hosts '127.0.0.1', 'localhost'
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  self.use_transactional_fixtures = false
  setup do
    DatabaseCleaner.start
    ActiveRecord::Fixtures.create_fixtures("#{File.dirname(__FILE__)}/../../../nimbleshop_core/test/fixtures", ['shops', 'link_groups', 'payment_methods'])
  end
  teardown do
    DatabaseCleaner.clean
  end

  def playcasette(casette)
    VCR.use_cassette(casette)  { yield }
  end
end
