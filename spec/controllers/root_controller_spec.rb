require 'rails_helper'

describe RootController, type: :controller do
  describe '#index' do
    context 'when format is invalid' do
      it { expect { get(:index, format: :json) }.to raise_error(ActionController::UnknownFormat) }
    end

    context 'when all is ok' do
      before { get :index }

      it { expect(response.status).to eq 200 }
    end
  end
end
