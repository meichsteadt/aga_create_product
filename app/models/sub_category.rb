class SubCategory
  attr_accessor(:id, :name, :parent_category, :products, :thumbnail)

  def initialize(params)
    @id = params[:id]
    @name = params[:name]
    @parent_category = params[:parent_category]
    @thumbnail = params[:thumbnail]
    @products = []
  end

  def create
    payload = {sub_category: JSON.parse(self.to_json)}
    res = RestClient.post("#{ENV['URL']}/categories", payload, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])})
    if JSON.parse(res)["status"] == 200
      self.id = JSON.parse(res)["sub_category"]["id"]
      true
    else
      false
    end
  end

  def destroy
    res = RestClient.delete("#{ENV['URL']}/categories/#{self.id}",  {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])})
    if JSON.parse(res)["status"] === 202
      true
    else
      false
    end
  end

  def update_products(method)
    payload = create_payload(method)
    JSON.parse(RestClient.put("#{ENV['URL']}/categories/#{self.id}", payload, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])}))
  end

  def get_category_products(category)
    products = []
    JSON.parse(RestClient.get("#{ENV['URL']}/#{category}/")).each do |product|
      unless product.nil?
        products << Product.new({
          id: product["id"],
          name: product["name"],
          number: product["number"],
          thumbnail: product["thumbnail"],
          images: product["images"],
          category: product["category"]
          })
      end
    end
    products
  end

  def get_products
    products = []
    JSON.parse(RestClient.get("#{ENV['URL']}/products?sub_category=#{self.id}"))["products"].each do |product|
      unless product.nil?
        products << Product.new({
          id: product["id"],
          name: product["name"],
          number: product["number"],
          thumbnail: product["thumbnail"],
          images: product["images"],
          category: product["category"]
          })
      end
    end
    products
  end

  def self.get_subcategories(category)
    JSON.parse(RestClient.get("#{ENV['URL']}/sub_categories/#{category}").to_s)
  end

  def self.get_subcategory(id)
    JSON.parse(RestClient.get("#{ENV['URL']}/categories/#{id}"))
  end

  def self.all(category)
    res = SubCategory.get_subcategories(category)
    @sub_categories = []
    res["sub_categories"].each do |sc|
      @sub_categories << SubCategory.new({
        id: sc["id"],
        name: sc["name"],
        parent_category: sc["parent_category"]
        })
    end
    @sub_categories
  end

private
  def create_payload(method)
    {"sub_category": JSON.parse(self.to_json), method: method}
  end
end
