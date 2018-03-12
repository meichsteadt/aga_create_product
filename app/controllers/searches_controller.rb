require 'csv'
class SearchesController < ApplicationController
  def index
    @search_params = params[:search]
    @category = params[:category]
    @products = []
    if @search_params && @category
      CSV.read("#{@category}.csv", headers: true).each do |row|
        if compare(row, @search_params)
          @product = Product.new(name: row["name"], number: row["number"], description: row["description"], category: row["category"])
          @products << @product
        end
      end
    end
  end

  def show
    @number = params[:number]
    @category = params[:category]
    @sub_categories = get_subcategories
    CSV.read("#{@category}.csv", headers: true).each do |row|
      if @number == row["number"]
        @product = Product.new(name: row["name"], number: row["number"], description: row["description"], category: row["category"])
      end
    end
    @product_items = []
    @price_book = {}
    CSV.read("2018price_book.csv", headers: true).each do |price_book|
      @price_book[price_book["Item#"]] = price_book[" Price "]
      @price_book[price_book["Item#"]] ? @price_book[price_book["Item#"]] = price_book[" Price "].delete("$ ") : false
    end
    CSV.read("#{@category}_product_items.csv", headers: true).each do |row|
      if row["product_number"] == @number
        @price_book[row["number"]] ? price = @price_book[row["number"]] : price = nil
        @product_item = ProductItem.new(number: row["number"], description: row["description"], dimensions: row["dimensions"], price: price)
        @product_items << @product_item
      end
    end
  end

  def create
    @search = params[:search]
    @category = params[:category]
    redirect_to "/searches?search=#{@search};category=#{@category}"
  end

private
  def compare(row, search_params)
    regex = /#{search_params}/
    if regex =~ row["name"] || regex =~ row["number"]
      return true
    end
    false
  end

  def get_subcategories
    sub_categories = Product.get_subcategories
    temp_arr = []
    length = (sub_categories.length/4).ceil
    temp_arr.push(sub_categories[0..length], sub_categories[length + 1..length * 2 + 1], sub_categories[length * 2 + 2..length * 3 + 2], sub_categories[length * 3 + 3..-1])
    sub_categories = temp_arr
    sub_categories
  end
end
