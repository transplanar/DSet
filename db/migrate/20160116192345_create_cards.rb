# REVIEW have a table include an array? (type) Or just parse multi-type?
# NO!!! Use split method http://stackoverflow.com/questions/4847499/how-do-i-convert-a-comma-separated-string-into-an-array

# TODO add serialize to fields type, category, strategy
# http://api.rubyonrails.org/classes/ActiveRecord/Base.html

class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :name
      t.string :image_url
      t.integer :cost
      t.string :types
      t.string :category
      t.string :expansion
      t.string :strategy
      t.string :terminality

      t.timestamps null: false
    end
  end
end
