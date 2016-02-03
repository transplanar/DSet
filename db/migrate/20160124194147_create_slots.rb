class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      # t.string :sql_query
      t.integer :selected_card

      t.timestamps null: false
    end
  end
end
