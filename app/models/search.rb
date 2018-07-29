class Search
  attr_reader(:query)

  def initialize(params)
    @query = params[:query]
  end

  def search
    products = []
    JSON.parse(RestClient.get("#{ENV['URL']}/searches?search=#{self.query}"))["products"].each do |product|
      products << Product.new({
        id: product["id"],
        number: product["number"],
        category: product["category"],
        images: product["images"]
        })
    end
    products
  end
end
