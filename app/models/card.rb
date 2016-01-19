class Card < ActiveRecord::Base


  # def self.search(search)
  #   if search
  #     # find(:all, :conditions => ['name LIKE ?', "%#{:search}%"])
  #     where('name LIKE ?', "%#{:search}%")
  #   else
  #     # self.all
  #     # REVIEW this was reccommended. Explain?
  #     # does not perform query
  #     # https://www.youtube.com/watch?v=_hMp2SAsWXw
  #     # scoped
  #   end
  # end

  def self.search search

    puts "SEARCH = #{search}"
    # unless params[:search].blank?
    unless search.blank?
      @results = Hash.new

      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at']
      columns = Card.attribute_names - exclude_columns

      @cards = []

      columns.each do |col|
          cards = Card.where("#{col} LIKE ?","%#{search}%")
          @results[col]  = cards unless cards.empty?
      end

      # Output results for testing
      # puts ">>>>>>>Results #{@results}"
      #
      # @results.each do |k,v|
      #   v.each do |card|
      #     puts "Card = #{card[:name]} in #{k}"
      #   end
      # end
      #>>>>>>>>>>>>>>>>>>>>>>>>>

    else
      @results = {}
    end
  end
end
