module ExchangeRates
  class Push
    def initialize(exchange_rate)
      @exchange_rate = exchange_rate.decorate
    end

    def call
      ActionCable.server.broadcast 'exchange_rate', rate_value: @exchange_rate.human_rate_value
    end
  end
end
