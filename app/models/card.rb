class Card < ActiveRecord::Base


  def self.search(search)
    if search
      # find(:all, :conditions => ['name LIKE ?', "%#{:search}%"])
      where('name LIKE ?', "%#{:search}%")
    else
      # self.all
      # REVIEW this was reccommended. Explain?
      # does not perform query
      # https://www.youtube.com/watch?v=_hMp2SAsWXw
      scoped
    end
  end
end
