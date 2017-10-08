class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :name
      t.string :image_url
      t.integer :cost
      t.string :card_types
      t.string :category
      t.string :expansion
      t.string :strategy
      t.string :terminality

      t.timestamps null: false
    end
  end
end
