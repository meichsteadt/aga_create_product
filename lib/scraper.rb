require 'csv'
class Scraper
  attr_accessor :url, :response, :product, :category, :sub_categories, :dimensions, :description, :images, :name, :number, :price_book, :product_items, :categories_book, :sub_categories_book, :image_urls

  def initialize(number, image_urls)
    @number = number
    @categories_book = set_categories_book
    @category = convert_category
    @price_book = set_price_book
    @sub_categories_book = get_subcategories
    @url = "https://homelegance.com/#{@category}/#{group_number(number)}.htm"
    @response = get_response
    @image_urls = image_urls
    @images = get_images
    @description
    @name
    @product_items = []
    @product = create_product
    @sub_categories = predict_sub_categories
  end

  def get_product_info(i=0)
    begin
    @num_name = @response.css("body > div:nth-child(2) > div > div.share > div:nth-child(1) > span").first.text.strip.split("    ")
    @name = @num_name[1]
    @number = @num_name[0]
    @description = @response.css("body > div:nth-child(2) > div > div:nth-child(9)").first.children[2].text.strip
    @product_items = @response.css("body > div:nth-child(2) > div > table").first.children.select{|e| e.name == "tr"}.map {|m| m.children}.map{ |m| m.select {|s| s.name == "td"}.map {|e| e.text.strip}}.drop(1)
    # @images = @response.css(".zoom-desc").map {|m| "https://homelegance.com" + m.children.select{ |s| s.name == "a"}.first.attributes["href"].value}
    rescue
      if i < 3
        try_new_url(i)
      end
    end
  end

  def try_new_url(i)
    if i == 0
      @url = "https://homelegance.com/#{@category}/#{@number}.htm"
    elsif i == 1
      search_products
    elsif i == 2
      @url = "https://homelegance.com/#{@category}/#{@number.delete("*")}.htm"
    elsif condition

    end
    i+= 1
    get_response
    get_product_info(i)
  end

  def get_response
    @response = Nokogiri::HTML(RestClient.get(@url).to_s)
    if @response.css("h1").first =~ "Sorry"
      @url = "https://homelegance.com/new_arrivals/#{group_number(@number)}.htm"
      @response = Nokogiri::HTML(RestClient.get(@url).to_s)
    end
    return @response
  end

  def search_products
    @search = "https://www.homelegance.com/search.htm?q=#{@number}"
    res = Nokogiri::HTML(RestClient.get(@search).to_s)
    res.css(".collects").length.times do |i|
      unless res.css("#collects_#{i}").children.empty?
        link = res.css("#collects_#{i}").children[1].attributes["href"].value
        @url = "https://homelegance.com#{link}"
        if @url =~ /#{@category}/
          break
        end
      end
    end
  end

  def set_price_book
    csv = CSV.read("2018_new_pricebook.csv", headers:true)
    @price_book = (csv.select {|s| s[" New Price "]}.map {|m| [m["Item#"], m[" New Price "].delete("$").delete(",").to_f] } + csv.select {|s| s[" New Price "].nil? && s[" Price "]}.map {|m| [m["Item#"], m[" Price "].delete("$").delete(",").to_f] }).to_h
  end

  def set_categories_book
    csv = CSV.read("2018_new_pricebook.csv", headers:true)
    csv.select {|s| s["Page"]}.map {|m| [m["Item#"], m["Page"][0]] }.to_h
  end

  def create_product
    self.get_product_info
    unless @product_items.empty?
      @product_items.each do |pi|
        pi.insert(1, @price_book[pi[0]])
      end
      @product = Product.new(
        description: @description,
        number: @number,
        category: @category,
        sub_categories: @sub_categories,
        images: @images,
        name: @name
      )
      @product.product_items = @product_items
      return @product
    end
  end

  def convert_category
    category_page = @categories_book[@number]
    if category_page == "B"
      return "bedroom"
    elsif category_page == "D"
      return "dining"
    elsif category_page == "S"
      return "seat"
    elsif category_page == "Y"
      return "youth"
    end
    # elsif category_page == "T"
    #   return "seat"
    # elsif category_page == "H"
    #   return "seat"
  end

  def group_number(number)
    if @category  == "bedroom"
      return number.split("-").first + "-1*"
    elsif @category  == "dining"
      return number
    elsif @category == "seat"
      return number
    elsif @category == "youth"
      if number.split("-").length > 1 && number.split("-")[1] =~ /1/
        return number.split("-").first + "-1*"
      else
        return number
      end
    end
  end

  def predict_sub_categories
    sc = []
    if @category == "bedroom"
      sc << "Bedroom Sets" unless @product_items.select{|e| e[0] =~ /-4/}.empty?
      sc << "Beds/Headboards" unless @product_items.select{|e| e[0] =~ /-1/}.empty?
    elsif @category == "dining"
      sc << "Dining Sets" unless @product_items.select {|e| e[2] =~ (/Dining Table/i) }.empty?
      sc << "Buffets/Hutches" unless @product_items.select {|e| e[0] =~ /-50\*/ }.empty?
      sc << "Servers" unless @product_items.select {|e| e[0] =~ /-55/ }.empty?
      sc << "Counter Height Dining Sets" unless @product_items.select {|e| e[2] =~ (/Counter Height Table/i) }.empty?
    end
    @product.sub_categories = sc if @product
    @sub_categories = sc
  end

  def get_subcategories
    # Product.get_subcategories.map {|e| [e["name"], e["id"]]}.to_h
  end

  def self.write_csv(product_numbers, image_urls)
    require 'csv'
    products = []
    product_items = {}
    max_product_items = 1
    product_numbers.each do |number|
      scraper = Scraper.new(number, image_urls)
      product = scraper.product
      if product
        product.category = "seating" if product.category == "seat"
        max_product_items = product.product_items.length if product.product_items.length > max_product_items
        to_row = JSON.parse(product.to_json).values
        to_row.each_with_index {|e, i| to_row[i] = e.join(", ") if e.class == Array && e[0].class != Array}
        products << to_row if !products.include?(to_row)
      end
    end
    CSV.open("public/missing_items_prelim.csv", "w") do |row|
      headers = JSON.parse(Product.new({}).to_json).keys
      headers.pop
      max_product_items.times do |i|
        headers << "product_item_#{i + 1}_number"
        headers << "product_item_#{i + 1}_price"
        headers << "product_item_#{i + 1}_description"
        headers << "product_item_#{i + 1}_dimensions"
      end
      row << headers
      products.each do |product|
        new_row = product[0..-2]
        product[-1].each {|e| e.each {|ee| new_row << ee}}
        row << new_row
      end
    end
  end

  def get_images
    @image_urls.select{|s| !(s =~ /copy/)}.select {|s| s=~ /#{@number.split("-")[0]}/}.map {|e| e.split("?").first}
  end

  def self.image_urls
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    bucket = s3.bucket('homelegance')
    bucket.objects.map {|e| e.presigned_url(:get)}
  end
end
