class UpdatePricesController < ApplicationController
  def index
    @price = PriceCsv.new()
  end

  def edit
  end

  def create
    @file = params[:price_csv][:file].tempfile
    require 'csv'
    csv = CSV.read(@file, headers: true)
    @hash = {}
    csv.each do |row|
      if row[" New Price "]
        @hash[row["Item#"]] = row[" New Price "].remove(" ", "$").to_f.ceil
      end
    end
    @product_items = PriceCsv.get_prices_to_update(@hash)
    @pi = PriceCsv.new()
  end

  def update
    @npp = new_price_params[:new_price].to_json
    res = PriceCsv.update_prices(@npp)
    flash[:notice] = res[:message]
    redirect_to '/update_prices'
  end

private
  def new_price_params
    params.tap do |whitelisted|
      whitelisted[:new_price] = params[:new_price]
    end
  end
end
