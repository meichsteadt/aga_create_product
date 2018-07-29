class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_categories, only: [:index, :show, :new]
  def index
    @sub_categories = SubCategory.all(@parent_category)
  end

  def show
    @sub_category_products = @category.get_products.sort_by {|e| e.number}
    ids = @sub_category_products.map {|m| m.id}
    @category_products = @category.get_category_products(@parent_category).map {|m| m unless ids.include?(m.id)}.compact.sort_by {|e| e.number}
  end

  def new

  end

  def create
    @sub_category = SubCategory.new(sub_category_params)
    if @sub_category.create
      flash[:notice] = "category successfully created"
      redirect_to category_path(@sub_category.id)
    else

    end
  end

  def edit

  end

  def update
    @add_products = params[:add_products].map {|e| e.to_i} if params[:add_products]
    @delete_products = params[:delete_products].map {|e| e.to_i} if params[:delete_products]
    if @add_products
      @category.products = @add_products
      @res = @category.update_products("add")
    elsif @delete_products
      @category.products = @delete_products
      @res = @category.update_products("delete")
    end
    flash[:notice] = @res[:message]
    redirect_to category_path(@category.id)
  end

  def destroy
    if @category.destroy
      flash[:notice] = "category successfully deleted"
      redirect_to categories_path
    else
      flash[:notice] = "something went wrong"
      redirect_to category_path(@category.id)
    end
  end

private

  def set_category
    @call = SubCategory.get_subcategory(params[:id])
    @category = SubCategory.new({id: @call["id"], name: @call["name"], parent_category: @call["parent_category"]})
  end

  def set_parent_categories
    @parent_categories = ["bedroom", "dining", "home", "occasional", "seating", "youth"]
    params[:parent_category] ? @parent_category = params[:parent_category] : @parent_category = "bedroom"
  end

  def sub_category_params
    params.permit(:name, :thumbnail, :parent_category)
  end

end
