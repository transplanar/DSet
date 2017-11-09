class CreateCardKeywords < ActiveRecord::Migration
  def change
    create_table :card_keywords do |t|
      t.string :name
      t.string :category
      t.string :description
      t.references :card, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
