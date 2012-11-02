namespace :nimbleshop do

  namespace :setup do

    desc "sets up database for nimbleshop application"
    task :db => :environment do

      Rake::Task["db:reset"].invoke if Rails.env.development? || Rails.env.test?

      Rake::Task["db:seed"].invoke

      puts "Loading sample data ..."
      Sampledata::Data.new.populate

      puts "Loading paymen records ..."
      Rake::Task["nimbleshop_splitable:load_record"].invoke
      Rake::Task["nimbleshop_paypalwp:load_record"].invoke
      Rake::Task["nimbleshop_authorizedotnet:load_record"].invoke
      Rake::Task["nimbleshop_cod:load_record"].invoke
      Rake::Task["nimbleshop_stripe:load_record"].invoke

      Rake::Task["nimbleshop_splitable:copy_images"].invoke
      Rake::Task["nimbleshop_paypalwp:copy_images"].invoke
      Rake::Task["nimbleshop_authorizedotnet:copy_images"].invoke
      Rake::Task["nimbleshop_cod:copy_images"].invoke
      Rake::Task["nimbleshop_stripe:copy_images"].invoke

      # set stripe to disabled because when both Authorize.net and
      # stripe are enabled then payment page has two credit card form
      # and that does not look nice visually
      NimbleshopStripe::Stripe.first.update_attributes! enabled: false

      puts ""
      puts '**** shop is ready with sample data ****'
    end

   end
 end
