class MissingItemsController < ApplicationController
  def index
    @mi = MissingItem.new()
  end

  def create
    require 'csv'
    @file = params[:missing_item][:file].tempfile
    csv = CSV.read(@file, headers: true)
    ds = CSV.read("ds.csv", headers: true)
    ds_book = ds.map {|row| [row["Model"], {status: row["Status"], add_desc: row["Additional_Description"]}]}.to_h
    @arr = []
    csv.each do |row|
      @arr << row["Item#"] if row["Item#"] && !row["Item#"].match(/([*]\d)/) && (ds_book[row["Item#"]] && !(ds_book[row["Item#"]][:status] == "DS" || ds_book[row["Item#"]][:add_desc] == "TBDS"))
    end
    @mi = missing_items(@arr)
    @third = (@mi.length/3).ceil
    @first_third = 0..@third
    @second_third = @third + 1..@third*2
    @last_third = @third * 2 + 1.. @mi.length - 1
  end

private
  def missing_items(arr)
    MissingItem.new.missing_items(arr)
  end

  def mi_params
    params.permit(:product_arr => [])
  end
end
