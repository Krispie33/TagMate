class CreateClothingItems < ActiveRecord::Migration[8.1]
  def change
    create_table :clothing_items do |t|
      t.text :care_summary
      t.jsonb :ai_raw_response  # Using jsonb for better indexing/searching

      t.integer :wash_temp      # as integer for numeric sorting/logic
      t.boolean :bleach_allowed, default: false
      t.boolean :tumble_dry,     default: false
      t.boolean :iron_allowed,   default: false
      t.boolean :dry_clean,      default: false

      # Relationships
      # A user should always own the item
      t.references :user, null: false, foreign_key: true

      # A drawer is optional (null: true) so you can scan items
      # into the system before organizing them.
      t.references :drawer, null: true, foreign_key: true

      t.timestamps
    end
  end
end
