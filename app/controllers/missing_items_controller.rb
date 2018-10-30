class MissingItemsController < ApplicationController
  def index
    @mi = MissingItem.new()
  end

  def create
    require 'csv'
    @file = params[:missing_item][:file].tempfile
    csv = CSV.read(@file, headers: true)
    @arr = []
    csv.each do |row|
      @arr << row["Item#"] if row["Item#"] && !row["Item#"].match(/([*]\d)/)
    end
    @mi = missing_items(@arr)
    @third = (@mi.length/3).ceil
    @first_third = 0..@third
    @second_third = @third + 1..@third*2
    @last_third = @third * 2 + 1.. @mi.length - 1
  end

private
  def missing_items(arr)
    MissingItem.new().missing_items(arr)
  end

  def mi_params
    params.permit(:product_arr => [])
  end
end
