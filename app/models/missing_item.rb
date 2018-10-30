class MissingItem < ApplicationRecord
  has_attached_file :file

  def missing_items(arr)
    JSON.parse(RestClient.post("#{ENV['URL']}/missing_items.json", {product_arr: arr}, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])}).to_s)
  end
end
