class CreateDrawers < ActiveRecord::Migration[8.1]
  def change
    create_table :drawers do |t|
      t.string :name
      t.text :instructions
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
