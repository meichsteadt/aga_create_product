class AddAttachmentFileToPriceCsvs < ActiveRecord::Migration[5.0]
  def change
    create_table :price_csvs do |t|
      t.string :name
      t.attachment :file
    end
  end

  # def self.down
  #   remove_attachment :price_csvs, :file
  # end
end
