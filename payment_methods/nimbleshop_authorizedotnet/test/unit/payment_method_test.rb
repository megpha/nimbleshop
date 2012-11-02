require "test_helper"

class PaymentMethodAuthorizeNetTest < ActiveSupport::TestCase

  test "validations" do
    pm = NimbleshopAuthorizedotnet::Authorizedotnet.new(name: 'Authorize.net', description: 'this is description')
    refute pm.valid?
    expected = ["Business name can't be blank", "Api Login Id can't be blank", "Transaction key can't be blank"]
    assert_equal expected.sort, pm.errors.full_messages.sort
  end

  test "should save the record" do
    pm = NimbleshopAuthorizedotnet::Authorizedotnet.new(name: 'Authorize.net', description: 'this is description')
    pm.api_login_id = 'FWERSDEED093d'
    pm.transaction_key = 'SDFSDFSFSF423433SDFSFSSFSFSF334'
    pm.business_name = 'BigBinary LLC'
    assert pm.save
    assert_match /authorize-net/, pm.permalink
  end
end

class PaymentMethodAuthorizeNetKaptureTest < ActiveSupport::TestCase
  setup do
    class HackedProcessor < NimbleshopAuthorizedotnet::Processor
      def kapture(*args); end
    end
  end

  test '#kapture!' do
    order = create :order_paid_using_authorizedotnet
    adnt = NimbleshopAuthorizedotnet::Authorizedotnet.new(name: 'Authorize.net', description: 'this is description')
    adnt.kapture!(order, HackedProcessor)
    assert_equal 'purchased', order.payment_status
  end
end
