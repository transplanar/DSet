class CardKeyword < ActiveRecord::Base
  belongs_to :card
  
  validates :name, presence: true
  validates :card, presence: true
  validates :category, presence: true
  validates :description, presence: true
 
#   t.string :name
#       t.string :category
#       t.string :description
#       t.references :card, index: true, foreign_key: true
end

