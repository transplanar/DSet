class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.integer :card_id
      t.string :queries
      # REVIEW is this correct?
      t.integer :selected_card

      t.timestamps null: false
    end

    add_index :slots, :card_id
  end
end
