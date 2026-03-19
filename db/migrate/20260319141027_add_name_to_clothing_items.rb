class AddNameToClothingItems < ActiveRecord::Migration[8.1]
  def change
    add_column :clothing_items, :name, :string
  end
end
