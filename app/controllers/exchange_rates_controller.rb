class ExchangeRatesController < ApplicationController
  # GET /admin
  def edit
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /admin
  def update
    respond_to do |format|
      if exchange_rate.update(exchange_rate_params.merge(rate_at: rate_at))
        format.html { redirect_to admin_path, notice: 'Курс доллара успешно обновлён.' }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def exchange_rate_params
    params.require(:exchange_rate).permit(:rate_at, :rate_value)
  end

  def rate_at
    return unless exchange_rate_params[:rate_at].present?

    exchange_rate_params[:rate_at].to_time.utc
  end
end
