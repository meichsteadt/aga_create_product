class CreateMissingItems < ActiveRecord::Migration[5.0]
  def change
    create_table :missing_items do |t|
    end
  end
end
