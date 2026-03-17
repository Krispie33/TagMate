class RemoveTypeFromMachines < ActiveRecord::Migration[8.1]
  def change
    remove_column :machines, :type, :string
  end
end
