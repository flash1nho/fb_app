class ExchangeRate < ApplicationRecord
  CURRENCY = {empty: 0, usd: 'Доллар', eur: 'Евро'}.freeze

  enum currency: CURRENCY.keys, _prefix: true

  validates :currency, :rate_at, :rate_value, presence: true
  validates :rate_at, timeliness: {type: :datetime, after: :now}, if: proc { |record| record.rate_at.present? }
  validates :rate_value,
            numericality: {greater_than_or_equal_to: 0},
            if: proc { |record| record.rate_value.present? }

  after_update_commit :push_to_web, :create_job

  private

  def push_to_web
    ExchangeRates::Push.new(self).call
  end

  def create_job
    Resque.remove_delayed(ExchangeRateJob, force: true)
    Resque.enqueue_at(rate_at, ExchangeRateJob, force: true)
  end
end
