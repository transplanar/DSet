class AddSlotToCards < ActiveRecord::Migration
  def change
    add_column :cards, :slot_id, :integer
    add_index :cards, :slot_id
  end
end
