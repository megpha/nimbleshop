require "test_helper"

class PaymentMethodStripeTest < ActiveSupport::TestCase

  test "validations" do
    pm = NimbleshopStripe::Stripe.new(name: 'Stripe', description: 'this is description')
    refute pm.valid?
    expected = ["Business name can't be blank", "Publishable key can't be blank", "Secret key can't be blank"].sort
    assert_equal expected, pm.errors.full_messages.sort
  end

  test "should save the record" do
    pm = NimbleshopStripe::Stripe.new(name: 'Stripe', description: 'this is description')
    pm.publishable_key = 'FWERSDEED093d'
    pm.secret_key = 'SDFSDFSFSF423433SDFSFSSFSFSF334'
    pm.business_name = 'BigBinary LLC'
    assert pm.save
    assert_match /stripe/, pm.permalink
  end

end
