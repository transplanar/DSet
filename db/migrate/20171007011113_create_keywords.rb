class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :name
      t.string :description
      t.string :type
      t.references :card, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
