class ProductItem
  attr_reader(:number, :description, :dimensions, :product_number)

  def initialize(params)
    @number = params[:number]
    @description = params[:description]
    @dimensions = params[:dimensions]
    @product_number = params[:product_number]
  end

  def create

  end
end
