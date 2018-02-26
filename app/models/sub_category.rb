class SubCategory
  attr_reader(:name, :parent_category)

  def initialize(params)
    @name = params[:name]
    @parent_category = params[:parent_category]
  end

  def self.get_subcategories(category)
    JSON.parse(RestClient.get("https://homelegance-kiosk.herokuapp.com/sub_categories/#{category}").to_s)
  end
end
