require 'rails_helper'

describe ExchangeRateJob, type: :job do
  let!(:exchange_rate) { create :exchange_rate }
  let(:job) { described_class }
  let(:parser_mock) { double('ExchangeRates::Parser') }

  describe '.perform' do
    before { allow(ExchangeRates::Parser).to receive(:new).with(exchange_rate, true).and_return(parser_mock) }
    before { allow(parser_mock).to receive(:call) }
    before { job.perform(force: true) }
    
    it { expect(parser_mock).to have_received(:call) }
  end
end
