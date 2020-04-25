require 'rails_helper'

describe ExchangeRates::Push, type: :service do
  let!(:exchange_rate) { create(:exchange_rate).decorate }
  let(:service) { described_class.new(exchange_rate) }
  let(:broadcast_mock) { double('ActionCable') }

  describe '#call' do
    before do
      allow(ActionCable).to receive(:server).and_return(broadcast_mock)
      allow(broadcast_mock).
        to receive(:broadcast).with('exchange_rate', {rate_value: exchange_rate.human_rate_value})

      service.call
    end

    it { expect(broadcast_mock).to have_received(:broadcast) }
  end
end
