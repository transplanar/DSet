class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.string :queries
      t.integer :selected_card
      t.string :image_url

      t.timestamps null: false
    end
  end
end
