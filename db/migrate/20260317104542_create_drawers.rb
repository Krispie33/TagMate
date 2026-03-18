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



#   def change
#     create_table :drawers do |t|
#       t.string :name, null: false
#       t.string :signature, null: false
#       t.text :instructions_summary
#       t.references :user, null: false, foreign_key: true

#       t.timestamps
#     end

#     add_index :drawers, [:user_id, :signature], unique: true
#   end
# end
