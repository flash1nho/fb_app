class ExchangeRateDecorator < Draper::Decorator
  delegate_all

  include ActionView::Helpers::NumberHelper

  def human_rate_value
    @human_rate_value ||= number_to_currency(rate_value)
  end

  def rate_at_localtime
    return unless rate_at.present?

    @rate_at_localtime ||= rate_at.localtime.strftime('%d.%m.%Y %H:%M')
  end
end
