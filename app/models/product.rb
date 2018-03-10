class Product
  attr_reader(:id, :name, :images, :description, :number, :category, :product_items, :sub_categories)
  def initialize(params)
    @name = params[:name]
    @images = params[:images]
    @description = params[:description]
    @number = params[:number]
    @category = params[:category]
    @id = params[:id]
    @product_items = []
    @sub_categories = params[:sub_categories]
  end

  def create
    payload = create_payload
    res = RestClient.post("#{ENV['URL']}/products", payload, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])})
    if res
      self.id = JSON.parse(res.to_s)["product"]["id"]
      true
    else
      false
    end
  end

  def update(id)
    payload = create_payload
    res = RestClient.put("#{ENV['URL']}/products/#{id}", payload, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])})
  end

  def destroy
    res = RestClient.delete("#{ENV['URL']}/products/#{self.id}", {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])})
  end

  def self.products(page_number)
    JSON.parse(RestClient.get("#{ENV['URL']}/products?page_number=#{page_number}").to_s)
  end

  def self.product(id, user)
    JSON.parse(RestClient.get("#{ENV['URL']}/products/#{id}?user=#{user.aga_id}").to_s)
  rescue RestClient::NotFound
    false
  end

  def thumbnail(url)
    url.gsub('homelegance', 'homelegance-resized')
  end

  def id=(id)
    @id = id
  end

  def images=(images)
    @images = images
  end

  def self.last_product
    JSON.parse(RestClient.get("#{ENV['URL']}/products").to_s)['products'].sort_by {|e| e['id']}.last['id']
  end

  def self.first
    JSON.parse(RestClient.get("#{ENV['URL']}/products").to_s)['products'].sort_by {|e| e['id']}.first['id']
  end

  def self.get_subcategories
    JSON.parse(RestClient.get("#{ENV['URL']}/sub_categories.json"))
  end

  def save_images(images)
    if images
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      images.each do |image|
        file = image.tempfile
        name = image.original_filename
        bucket = 'homelegance'
        obj = s3.bucket(bucket).object(name)
        obj.upload_file(file, acl: 'public-read')
      end
    end
  end

  def create_payload
    payload = {"product": JSON.parse(self.to_json)}
  end
end
