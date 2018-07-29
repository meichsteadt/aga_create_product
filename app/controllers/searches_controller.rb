class SearchesController < ApplicationController
  def index

  end

  def show
    search = params[:search]
    if search
      search = Search.new({query: search})
      @products = search.search
    else
      @products = []
    end
  end
end
