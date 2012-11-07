if Rails.env.test?

elsif Nimbleshop.config.deliver_email

  # Setup how you want email to be delivered

else

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    user_name:      Nimbleshop.config.mailtrapio.username,
    password:       Nimbleshop.config.mailtrapio.password,
    address:        "mailtrap.io",
    port:           2525,
    authentication: :plain }

end
