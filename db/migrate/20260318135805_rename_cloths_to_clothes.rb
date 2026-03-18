class RenameClothsToClothes < ActiveRecord::Migration[8.1]
  def change
    rename_table :cloths, :clothes
  end
end
