class ExchangeRateChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'exchange_rate'
  end
end
