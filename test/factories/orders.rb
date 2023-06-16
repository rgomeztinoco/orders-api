FactoryBot.define do
  factory :order do
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    payment_status { Order::PAYMENT_STATUSES.values.sample }
    status { Order::STATUSES.values.sample }
    user
  end

  factory :delivered_order, parent: :order do
    status { Order::STATUSES[:delivered] }
  end

  factory :preparing_order, parent: :order do
    status { Order::STATUSES[:preparing] }
  end
end
