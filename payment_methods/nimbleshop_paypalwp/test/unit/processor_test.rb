require 'test_helper'

module Processor
  class PaypalAuthorizeTest < ActiveRecord::TestCase
    def raw1
      "mc_gross=152.73&invoice=54145619&protection_eligibility=Ineligible&item_number1=&payer_id=Q96HQCW3NMN8A&tax=1.73&payment_date=19%3A48%3A59+Apr+22%2C+2012+PDT&payment_status=Completed&charset=windows-1252&mc_shipping=0.00&mc_handling=10.00&first_name=buyer&mc_fee=4.73&notify_version=3.4&custom=&payer_status=verified&business=seller_1323037155_biz%40bigbinary.com&num_cart_items=1&mc_handling1=0.00&verify_sign=AAmQuqWvZCTtQW5vSunjl6MYb9xfACAPVvn0EpIPnon.Cyn5sYgI-bZB&payer_email=nimble_1333550340_per%40hotmail.com&mc_shipping1=0.00&tax1=0.00&txn_id=2LY704674J0179216&payment_type=instant&last_name=again&item_name1=Colorful+shoes&receiver_email=seller_1323037155_biz%40bigbinary.com&payment_fee=4.73&quantity1=1&receiver_id=EULE94DW3YTH4&txn_type=cart&mc_gross_1=141.00&mc_currency=USD&residence_country=US&test_ipn=1&transaction_subject=Shopping+CartColorful+shoes&payment_gross=152.73&ipn_track_id=72a7efbc940b7"
    end

    def raw_post(order_id, total)
      "mc_gross=#{total}&invoice=#{order_id}&protection_eligibility=Ineligible&item_number1=&payer_id=UU9QTKRET6CCA&tax=0.23&payment_date=13%3A46%3A50+Apr+01%2C+2012+PDT&payment_status=Completed&charset=windows-1252&mc_shipping=0.00&mc_handling=0.00&first_name=venkata&mc_fee=0.63&notify_version=3.4&custom=&payer_status=verified&business=pvdsub_1332777111_biz%40hotmail.com&num_cart_items=1&mc_handling1=0.00&verify_sign=A97HaEBl1Z9n6y3FnK2ES7ntmCFAA42qVBV1tGxSqeM5XnO3fijruk.r&payer_email=pvdsub_1332813592_per%40hotmail.com&mc_shipping1=0.00&tax1=0.00&txn_id=48D08257JB6543456&payment_type=instant&last_name=pasupuleti&item_name1=Handmade+vibrant+bangles&receiver_email=pvdsub_1332777111_biz%40hotmail.com&payment_fee=0.63&quantity1=1&receiver_id=DT54LCN8WQM8S&txn_type=cart&mc_gross_1=11.00&mc_currency=USD&residence_country=US&test_ipn=1&transaction_subject=Shopping+CartHandmade+vibrant+bangles&payment_gross=11.23&ipn_track_id=b1f9dd1a56ae8"
    end

    setup do
      @order = create(:order)
    end

    test "when purchase succeeds" do
      processor = NimbleshopPaypalwp::Processor.new(raw_post: raw_post(@order.number, @order.total_amount))
      assert_equal true, processor.purchase

      @order.reload

      transaction = @order.payment_transactions.last
      assert_equal 'purchased', transaction.operation
      assert_equal true, @order.purchased?
      assert_match /April 01, 2012/, @order.purchased_at.to_s(:long)
      assert_equal NimbleshopPaypalwp::Paypalwp.first, @order.payment_method
      assert_equal transaction.amount, @order.total_amount_in_cents
    end

    test "when purchase fails" do
      processor = NimbleshopPaypalwp::Processor.new(raw_post: raw_post(@order.number, 10.48))
      assert_equal false, processor.purchase
      assert_nil @order.payment_method
    end
  end
end
