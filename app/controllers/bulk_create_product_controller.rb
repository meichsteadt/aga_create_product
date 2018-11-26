class BulkCreateProductController < ApplicationController
  def index
    @price = PriceCsv.new()
  end

  def create
    @file = params[:price_csv][:file].tempfile
    require 'csv'
    csv = CSV.read(@file, headers: true)
    @products = []
    @hash = {}
    @sub_categories = {}
    Product.get_subcategories.each do |e|
      @sub_categories[e["parent_category"]] = {} unless @sub_categories[e["parent_category"]]
      @sub_categories[e["parent_category"]][e["name"]] = e["id"]
    end
    csv.each do |row|
      @product = Product.new(
        number: row["number"],
        name: row["name"],
        description: row["description"],
        category: row["category"],
        images: row["images"].split(", "),
        sub_categories: row["sub_categories"].split(", ").map {|e| @sub_categories[row["category"]][e]}
      )
      i = 1
      while row["product_item_#{i}_number"]
        @product_item = ProductItem.new(
          number: row["product_item_#{i}_number"],
          price: row["product_item_#{i}_price"],
          description: row["product_item_#{i}_description"],
          dimensions: row["product_item_#{i}_dimensions"],
          product_number: row["number"]
        )
        @product.product_items << @product_item
        i+= 1
      end
      @products << @product
    end
    @products.each {|e| e.create(1)}
  end
end
