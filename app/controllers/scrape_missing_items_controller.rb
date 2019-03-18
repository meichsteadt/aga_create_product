class ScrapeMissingItemsController < ApplicationController
  def create
    require 'csv'
    @arr = params[:product_arr].split(" ")
    puts "missing items: #{@arr.length}"
    Scraper.write_csv(@arr, Scraper.image_urls)
    send_file('public/missing_items_prelim.csv')
  end

  def index
    send_file('public/missing_items_prelim.csv')
  end

private
  def missing_items(arr)
    MissingItem.new.missing_items(arr)
  end

  def scrape_mi_params
    params.permit(:product_arr => [])
  end
end
