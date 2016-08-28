class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.string :queries
      t.string :image_url
      t.string :sql_prepend
      t.string :filters_humanized

      t.timestamps null: false
    end
  end
end
