FactoryGirl.define do
  factory :creditcard do |f|
    cvv           '123'
    number        '4007000000027'

    first_name  { Faker::Name.first_name  }
    last_name   { Faker::Name.last_name   }
    address1    { Faker::Address.street_address }
    zipcode     { Faker::Address.zip_code }
    month         5
    year          2015
    state         'Florida'

    trait :visa do
      number    '4007000000027'
      cvv       '123'
    end

    trait :american_express do
      cvv       '1123'
      number    '370000000000002'
    end

    factory :visa_creditcard, traits: [:visa]
    factory :american_express_creditcard, traits: [:american_express]
  end
end
