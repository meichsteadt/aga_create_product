class AddHomericaBool < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :homerica, :boolean, :default => false
  end
end
