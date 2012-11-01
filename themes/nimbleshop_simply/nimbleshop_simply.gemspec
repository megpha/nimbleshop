# Encoding: UTF-8

$:.push File.expand_path('../../../nimbleshop_core/lib', __FILE__)
require 'nimbleshop/version'
version = Nimbleshop::Version.to_s

Gem::Specification.new do |gem|

  gem.name        = 'nimbleshop_simply'
  gem.version     = version
  gem.authors     = ['Neeraj Singh', 'megpha']
  gem.email       = ['neeraj@bigbinary.com']
  gem.homepage    = 'http://nimbleshop.org'
  gem.summary     = 'simply theme for nimbleShop'
  gem.description = 'Provides simply theme to nimbleShop'

  gem.files = Dir['{app,config,db,lib}/**/*'] + ['README.md']

  gem.test_files = Dir['test/**/*']

  gem.add_dependency 'jquery-rails', '~> 2.1.1'
  gem.add_dependency 'fancybox-rails', '= 0.1.4'
end
