FactoryBot.define do
  factory :exchange_rate do
    currency { ExchangeRate.currencies[:usd] }
    rate_at { 1.days.from_now }
    rate_value { 1.01 }
  end
end
