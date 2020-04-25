require 'rails_helper'

describe ExchangeRate, type: :model do
  describe 'validations' do
    let(:exchange_rate) { build :exchange_rate }

    it { expect(exchange_rate).to validate_presence_of(:currency) }
    it { expect(exchange_rate).to validate_presence_of(:rate_at) }
    it { expect(exchange_rate).to validate_presence_of(:rate_value) }
    it { expect(exchange_rate).to validate_numericality_of(:rate_value).is_greater_than_or_equal_to(0) }

    context 'when currency does not exist' do
      it { expect { exchange_rate.currency = 'uds' }.to raise_error(ArgumentError) }
    end

    context 'when rate at is invalid' do
      it do
        expect(exchange_rate).
          not_to allow_value('1', 'abc', '1.2', '0001-12-01', '2015-12-01', '2015-01-45').for(:rate_at)
      end
    end
  end

  describe 'after commit' do
    let!(:exchange_rate) { create :exchange_rate }
    let(:exchange_rate_push) { double('ExchangeRates::Push') }

    before do
      allow(ExchangeRates::Push).to receive(:new).with(exchange_rate).and_return(exchange_rate_push)
      allow(exchange_rate_push).to receive(:call)

      allow(Resque).to receive(:remove_delayed).with(ExchangeRateJob, force: true)
      allow(Resque).to receive(:enqueue_at).with(exchange_rate.rate_at, ExchangeRateJob, force: true)
     
      exchange_rate.update!(rate_value: 100)
    end

    it { expect(exchange_rate_push).to have_received(:call) }
    it { expect(Resque).to have_received(:remove_delayed) }
    it { expect(Resque).to have_received(:enqueue_at) }
  end
end
