class PriceCsvController < ApplicationController
  def index
    @csv_arr = PriceCsv.new().get_csv
    PriceCsv.new().write_csv(@csv_arr)
    send_file('current_kiosk_prices.csv')
  end
end
