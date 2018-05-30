class ProductsController < ApplicationController
  def index
    params[:page_number]? @page_number = params[:page_number].to_i : @page_number = 1
    @products = Product.products(@page_number)["products"]
    @pages = (Product.products(@page_number)["pages"]/6.0).ceil
    @next = next_page(@page_number, @pages)
    @prev = prev_page(@page_number, @pages)
  end

  def new
    @product = Product.new({})
    @proudct_items = []
    respond_to do |format|
      format.js
      format.html
    end
    @sub_categories = get_subcategories
  end

  def create
    update_image_params(params)
    @product = Product.new(product_params)
    product_item_params.each {|pi| pi['product_number'] = @product.number; @product.product_items << pi;}
    @product.images = filter_images(@product.images)
    if @product.create(current_user.warehouse_id)
      redirect_to edit_product_path(@product.id)
    else
      flash[:error] = "There was an error creating this product"
      redirect_to new_product_path
    end
  end

  def edit
    respond_to do |format|
      format.js
      format.html
    end
    @homerica_link = url_for(controller: 'homerica', action: 'index')
    @homerica = current_user.homerica
    @prod_call = Product.product(params[:id], current_user)
    if @prod_call
      @product = @prod_call["product"]
      @product_items = @prod_call["product_items"]
      @product_sub_categories = @prod_call["sub_categories"].map{|e| e['id'] }
    end
    if @homerica
      @product_items.each {|e| e["price"] = homerica_price(e["number"])}
    end
    @sub_categories = get_subcategories
    @last = Product.last_product
    @first = Product.first
    params[:dir] == "prev"? @to_id = params[:id].to_i - 1 : @to_id = params[:id].to_i + 1
    if @product
      set_product(@product.symbolize_keys)
    elsif params[:id].to_i <= @first && params[:dir] == "prev"
      redirect_to edit_product_path(@last)
    elsif params[:id].to_i >= @last && params[:dir] == "next"
      redirect_to edit_product_path(@first)
    elsif params[:id].to_i >= @last || params[:id].to_i <= @first
      redirect_to edit_product_path(@first)
    else
      redirect_to edit_product_path(@to_id, {dir: params[:dir]})
    end
  end

  def update
    if params[:image_files]
      update_image_params(params)
      @product = Product.new(product_params)
      # @product.save_images(@images)
    else
      @product = Product.new(product_params)
    end
    product_item_params.each {|pi| pi['product_number'] = @product.number; @product.product_items << pi;}
    @product.update(params[:id], current_user.warehouse_id)
    redirect_to edit_product_path(@product.id)
  end

  def destroy
    @product = Product.new({id: params[:id]})
    @product.destroy
    redirect_to edit_product_path(params[:to_id])
  end
private
  def product_params
    params.permit(:name, :number, :description, :category, :id, :images => [], :sub_categories => [])
  end

  def product_item_params
    params.permit(:product_items => [:number, :description, :dimensions, :price, :id])["product_items"]
  end

  def set_product(params)
    @product = Product.new(name: params[:name], number: params[:number], description: params[:description], images: params[:images], id: params[:id], category: params[:category])
  end

  def filter_images(images)
    arr = []
    images.each {|e| if e != ""; arr << e; end }
    arr
  end

  def next_page(page_number, pages)
    if page_number == pages
      return 1
    else
      return page_number + 1
    end
  end

  def prev_page(page_number, pages)
    if page_number == 1
      return pages
    else
      return page_number - 1
    end
  end

  def update_image_params(params)
    params[:images]? false : params[:images] = []
    @images = params[:image_files]
    if @images
       @images.each {|e| params[:images] << "https://s3-us-west-1.amazonaws.com/homelegance/#{e.original_filename}".gsub(' ', '+')}
    end
  end

  def get_subcategories
    sub_categories = Product.get_subcategories
    temp_arr = []
    length = (sub_categories.length/4).ceil
    temp_arr.push(sub_categories[0..length], sub_categories[length + 1..length * 2 + 1], sub_categories[length * 2 + 2..length * 3 + 2], sub_categories[length * 3 + 3..-1])
    sub_categories = temp_arr
    sub_categories
  end

  def homerica_price(number)
    require 'csv'
    prices = {}
    csv = CSV.read('homerica_prices.csv', headers: true)
    csv.each {|e| prices[e[0]] = e[1]}
    prices[number].to_f
  end
end
