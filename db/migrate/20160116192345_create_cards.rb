class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :title
      t.string :image_url
      t.integer :cost
      t.string :category
      t.string :expansion
      t.string :strategy
      t.string :string
      t.string :terminal

      t.timestamps null: false
    end
  end
end
