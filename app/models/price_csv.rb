class PriceCsv < ApplicationRecord
has_attached_file :file

  def self.get_prices_to_update(hash)
    JSON.parse(RestClient.post("#{ENV['URL']}/get_prices_to_update", {prices_hash: hash}, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])}).to_s)
  end

  def self.update_prices(hash)
    JSON.parse(RestClient.post("#{ENV['URL']}/update_prices", {prices_hash: hash}, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])}).to_s)
  end

end
