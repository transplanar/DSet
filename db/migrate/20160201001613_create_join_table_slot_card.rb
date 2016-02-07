class CreateJoinTableSlotCard < ActiveRecord::Migration
  def change
    create_join_table :slots, :cards do |t|
      t.index [:slot_id, :card_id]
      t.index [:card_id, :slot_id]
    end
  end
end
