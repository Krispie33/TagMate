class CreateClothingItems < ActiveRecord::Migration[8.1]
  def change
    create_table :clothing_items do |t|
      t.string :tag_image
      t.string :item_image
      t.text :care_summary
      t.integer :wash_temp
      t.boolean :bleach_allowed
      t.boolean :tumble_dry
      t.boolean :iron_allowed
      t.boolean :dry_clean
      t.json :ai_raw_response
      t.references :drawer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
