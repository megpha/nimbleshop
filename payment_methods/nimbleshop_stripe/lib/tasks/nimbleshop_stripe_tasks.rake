
namespace :nimbleshop_stripe do

  desc 'copies images from engine to main rails application'
  task :copy_images do
    engine_name = 'nimbleshop_stripe'
    origin = File.expand_path('../../app/assets/images', File.dirname(__FILE__))
    destination = Rails.root.join('app', 'assets', 'images', 'engines', engine_name)
    FileUtils.mkdir_p(destination) if !File.exist?(destination)
    Dir[File.join(origin, '**/*')].each { |file| FileUtils.cp(file, File.join(destination) ) unless File.directory?(file) }
  end

  desc 'load Stripe record'
  task :load_record => :environment do

    if NimbleshopStripe::Stripe.find_by_permalink('stripe')
      Rails.logger.debug "Stripe record already exists"
    else
      NimbleshopStripe::Stripe.create!(
        {
          publishable_key: Nimbleshop.config.stripe.publishable_key,
          secret_key: Nimbleshop.config.stripe.secret_key,
          business_name: 'Nimbleshop LLC',
          name: 'Stripe',
          permalink: 'stripe',
          description: %Q[<p> Stripe is a payment gateway service provider allowing merchants to accept credit card payments. </p>]
        })
        Rails.logger.debug "Stripe record was successfuly created"
    end
  end
end
