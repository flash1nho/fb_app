class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :exchange_rate

  private

  def exchange_rate
    @exchange_rate ||= ExchangeRate.first.decorate
  end
end
