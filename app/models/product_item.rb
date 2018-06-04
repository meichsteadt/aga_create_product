class ProductItem
  attr_reader(:number, :description, :dimensions, :product_number, :price, :id)

  def initialize(params)
    @number = params[:number]
    @description = params[:description]
    @dimensions = params[:dimensions]
    @product_number = params[:product_number]
    @price = params[:price]
    @id = params[:id]
  end

  def homerica_price
    require 'csv'
    prices = {}
    csv = CSV.read('homerica_prices.csv', headers: true)
    csv.each {|e| prices[e[0]] = e[1]}
    @price = prices[@number]
  end

  def create_price(amount, warehouse_id)
    amount.nil? ? amount = 0.0 : false
    RestClient.post("#{ENV['URL']}/product_items/#{self.id}/prices", {product_item_id: self.id, amount: amount, warehouse_id: warehouse_id}, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])})
  end
end
