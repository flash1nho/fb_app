require 'rails_helper'

describe ExchangeRatesController, type: :controller do
  describe '#edit' do
    context 'when format is invalid' do
      it { expect { get(:edit, format: :json) }.to raise_error(ActionController::UnknownFormat) }
    end

    context 'when all is ok' do
      before { get :edit }

      it { expect(response.status).to eq 200 }
    end
  end

  describe '#update' do
    let!(:exchange_rate) { create :exchange_rate }

    context 'when param is missing' do
      it { expect { put(:update) }.to raise_error(ActionController::ParameterMissing) }
    end

    context 'when format is invalid' do
      it do
        expect { put(:update, format: :json, params: {exchange_rate: {rate_at: nil}}) }.
          to raise_error(ActionController::UnknownFormat)
      end
    end

    context 'when exchange rate is not saved' do
      before { put :update, params: {exchange_rate: {rate_at: nil}} }

      it { expect(response.status).to eq 200 }
      it { expect(controller).to render_template(:edit) }
    end

    context 'when all is ok' do
      before do
        put :update, params: {exchange_rate: {rate_at: exchange_rate.rate_at, rate_value: exchange_rate.rate_value}}
      end

      it { expect(response.status).to eq 302 }
      it { expect(controller).to redirect_to(admin_path) }
      it { expect(controller.notice).to eq 'Курс доллара успешно обновлён.' }
    end

    it { should permit(:rate_at, :rate_value).for(:update, params: {exchange_rate: {param: nil}}) }
  end
end
