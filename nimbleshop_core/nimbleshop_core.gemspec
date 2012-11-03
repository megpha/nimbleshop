# Encoding: UTF-8

$:.push File.expand_path('../../nimbleshop_core/lib', __FILE__)
require 'nimbleshop/version'
version = Nimbleshop::Version.to_s
rails_version = Nimbleshop::RailsVersion.to_s

Gem::Specification.new do |gem|

  gem.name              = 'nimbleshop_core'
  gem.version           = version
  gem.authors           = ['Neeraj Singh', 'megpha']
  gem.email             = 'neeraj@BigBinary.com'
  gem.homepage          = 'http://nimbleShop.org'
  gem.required_ruby_version = '>= 1.9.2'

  gem.summary           = 'Core extension for nimbleShop'
  gem.description       = 'Provides core e-commerce support to nimbleShop'

  gem.files = Dir['{app,config,db,lib,vendor}/**/*'] + ['Rakefile', 'README.md']

  gem.test_files = Dir['test/**/*']

  gem.add_dependency 'rails', rails_version

  # for uploading images
  gem.add_dependency 'carrierwave', '= 0.6.2'

  # for background processing of jobs
  gem.add_dependency 'delayed_job_active_record', '= 0.3.2'

  gem.add_dependency 'twitter-bootstrap-rails', '= 2.1.0'

  # to manage states of payment_status and shipping_status
  gem.add_dependency 'state_machine', '= 1.1.2'

  # for creating thumbnails for images
  gem.add_dependency 'mini_magick', '= 3.4'

  # to handle payments
  gem.add_dependency 'activemerchant', '= 1.26.0'

  # This gem maintains all the country codes and subregions for some of the countries
  gem.add_dependency 'carmen', '= 1.0.0.beta2'

  # for having nested items. order has billing_address and shipping_address nested
  gem.add_dependency 'nested_form', '= 0.2.1'

  # for security
  gem.add_dependency 'strong_parameters', '= 0.1.3'

  gem.add_dependency 'valid_email', '= 0.0.4'

  # to override default error message that comes with validates_presence_of etla.
  gem.add_dependency 'custom_error_message', '= 1.1.1'

  # ruby 1.9 does not parse dates formatted in american style correclty. This gem fixes that.
  gem.add_dependency 'american_date', '= 1.0.0'

  # to make settings more flexible. Without hashr the code would be like this
  #  Nimbleshop.config.s3['bucket_name']  .With hashr it becomes Nimbleshop.config.s3.bucket_name
  #
  #  I can't use open-struct because that does not list all the keys
  gem.add_dependency 'hashr', '= 0.0.19'

  gem.add_dependency 'jquery-rails', '~> 2.1.1'
end
