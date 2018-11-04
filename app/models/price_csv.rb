class PriceCsv < ApplicationRecord
has_attached_file :file

  def self.get_prices_to_update(hash)
    JSON.parse(RestClient.post("#{ENV['URL']}/get_prices_to_update", {prices_hash: hash}, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])}).to_s)
  end

  def self.update_prices(hash)
    JSON.parse(RestClient.post("#{ENV['URL']}/update_prices", {prices_hash: hash}, {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])}).to_s)
  end

  def get_csv
    JSON.parse(RestClient.get("#{ENV['URL']}/price_csv", {key: Base64.encode64(ENV['KEY']), secret: Base64.encode64(ENV['SECRET'])}).to_s)
  end

  def write_csv(arr)
    require 'csv'
    CSV.open("current_kiosk_prices.csv", "w") do |row|
      row << ["Item#", " Price ", "Description", "Dimensions", "Group#"]
      arr.each {|e| row << e}
    end
  end

end
