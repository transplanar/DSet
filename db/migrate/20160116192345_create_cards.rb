class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :name
      t.string :image_url
      t.integer :cost

      t.timestamps null: false
    end
  end
end
