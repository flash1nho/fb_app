require 'rails_helper'

describe ExchangeRates::Parser, type: :service do
  let(:rate_at) { 1.days.from_now }
  let(:url) { 'http://www.cbr.ru/scripts/XML_daily.asp' }
  let!(:exchange_rate) { create :exchange_rate, rate_at: rate_at }
  let(:force) { true }
  let(:service) { described_class.new(exchange_rate, force) }

  let(:body) do
    <<-XML
      <?xml version="1.0" encoding="windows-1251"?>
      <ValCurs Date="25.04.2020" name="Foreign Currency Market">
        <Valute ID="R01111">
          <NumCode>035</NumCode>
          <CharCode>USD</CharCode>
          <Nominal>1</Nominal>
          <Name>доллар</Name>
          <Value>75,1234</Value>
        </Valute>
        <Valute ID="R01112">
          <NumCode>036</NumCode>
          <CharCode>EUR</CharCode>
          <Nominal>1</Nominal>
          <Name>евро</Name>
          <Value>1,1234</Value>
        </Valute>
      </ValCurs>
    XML
  end

  shared_examples 'force or not force' do
    context 'when api url does not exist' do
      let(:url) { 'http://does not exist' }

      before do
        stub_request(:get, url).
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
            }
          ).to_return(status: 200, body: body, headers: {})
      end

      before { stub_const('ExchangeRates::Parser::URL', url) }

      it { expect { service.call }.to raise_error(RuntimeError, 'Could not retrieve data from URL') }
    end

    context 'when response is ok' do
      before do
        stub_request(:get, url).
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
            }
          ).to_return(status: 200, body: body, headers: {})
      end

      context 'when body is blank' do
        let(:body) { '' }

        it { expect(service.call).to be_nil }
      end

      context 'when body is present' do
        let(:push_mock) { double('ExchangeRates::Push') }

        before { allow(ExchangeRates::Push).to receive(:new).with(exchange_rate).and_return(push_mock) }
        before { allow(push_mock).to receive(:call) }

        it { expect { service.call }.to change { exchange_rate.reload.rate_value }.from(1.01).to(75.1234) }

        it do
          service.call

          expect(push_mock).to have_received(:call)
        end
      end
    end
  end

  describe '#call' do
    context 'when force' do
      it_behaves_like 'force or not force'
    end

    context 'when not force' do
      let(:force) { false }

      context 'when exchange rate at is more than current time' do
        it { expect(service.call).to be_nil }
      end

      context 'when exchange rate at is less than current time' do
        let(:exchange_rate) { build :exchange_rate, rate_at: rate_at}
        let(:rate_at) { 1.days.ago }

        before do
          stub_request(:get, url).
            with(
              headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent'=>'Ruby'
              }
            ).to_return(status: 200, body: body, headers: {})
        end

        before { exchange_rate.save(validate: false) }

        it_behaves_like 'force or not force'
      end
    end
  end
end
