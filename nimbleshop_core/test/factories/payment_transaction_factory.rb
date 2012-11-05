FactoryGirl.define do
  factory :payment_transaction do

    order

    trait :splitable do
      transaction_gid "42826554YH061931A"
      operation 'purchased'
    end

    trait :paypalwp do
      transaction_gid "42826554YH061931A"
      operation 'purchased'
      amount 14237
    end

    trait :authorizedotnet do
      operation 'authorized'
      amount 11200
      transaction_gid "2172281042"
      params do
        { response_code: 1,
          response_reason_code: "1",
          response_reason_text: "This transaction has been approved.",
          avs_result_code: "Y",
          transaction_id: "2172281042",
          card_code: "P" }
      end
      metadata do
        { card_number: 'XXXX-XXXX-XXXX-0027', cardtype: 'visa' }
      end
    end

    factory :payment_transaction_with_splitable,         traits: [ :splitable ]
    factory :payment_transaction_with_paypalwp,          traits: [ :paypalwp ]

    factory :payment_transaction_with_authorizedotnet,   traits: [ :authorizedotnet ] do |pt|
      pt.after(:create) do |pt2|
        pt2.order.update_column(:payment_status, 'authorized')
      end
    end

  end
end
