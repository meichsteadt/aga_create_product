class SearchesController < ApplicationController
  def index

  end

  def create
    redirect_to search_path(query_params[:query])
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

private

  def query_params
    params.permit(:query)
  end
end
