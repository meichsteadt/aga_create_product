class ProductItem
  attr_reader(:number, :description, :dimensions, :product_number, :price)

  def initialize(params)
    @number = params[:number]
    @description = params[:description]
    @dimensions = params[:dimensions]
    @product_number = params[:product_number]
    @price = params[:price]
  end

  def homerica_price
    require 'csv'
    prices = {}
    csv = CSV.read('homerica_prices.csv', headers: true)
    csv.each {|e| prices[e[0]] = e[1]}
    @price = prices[@number]
  end

  def create

  end
end
