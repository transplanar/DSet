class Card < ActiveRecord::Base


  def self.search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{:search}%"])
    else
      self.all
    end
  end
end
