class AddAgaApiUserIndex < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :aga_id, :integer
  end
end
