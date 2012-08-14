require 'nimbleshop/engine'

require 'nimbleshop/nimbleshop/util'
require 'nimbleshop/nimbleshop/payment_util'
require 'generators/nimbleshop/app/install_generator'

# Why do we need to require all the gems individually ?
#
# When bundler loads a gem it also requires that gem unless you say require false.
# nimbleshop_core gem is loaded using gemspec and unlike bundler gemspec does not
# autoload the gems.

require 'rails/all'
require 'hashr'
require 'carrierwave'
require 'delayed_job_active_record'
require 'carmen'
require 'nested_form'
require 'twitter-bootstrap-rails'
require 'state_machine'
require 'mini_magick'
require 'active_merchant'
require 'strong_parameters'
require 'valid_email'
require 'custom_error_message'
require 'american_date'

