class CreateMachines < ActiveRecord::Migration[8.1]
  def change
    create_table :machines do |t|
      t.string :type
      t.string :brand
      t.string :model
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
