class ImagesController < ApplicationController
  def index

  end

  def create
    Product.new({}).save_images(image_params[:image_files])
  end

private
  def image_params
    params.permit(:image_files => [])
  end
end
