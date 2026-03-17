class CreateCloths < ActiveRecord::Migration[8.1]
  def change
    create_table :cloths do |t|
      t.string :tag_image
      t.text :tag_data
      t.string :cloth_image
      t.references :drawer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
