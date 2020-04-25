unless ExchangeRate.exists?
  ExchangeRate.create!(currency: ExchangeRate.currencies[:usd], rate_at: Time.now + 1.minutes, rate_value: 0)
end
