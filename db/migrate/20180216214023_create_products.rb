class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :number
      t.string :description
      t.string :category
    end

    add_attachment :products, :images, array: true
  end
end
