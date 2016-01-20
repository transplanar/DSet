class Card < ActiveRecord::Base
  # REVIEW How to index your model https://github.com/mezis/fuzzily#usage
  # fuzzily_searchable :name, :cost, :types, :category, :expansion, :strategy, :terminality
  fuzzily_searchable :name, :types, :category, :expansion, :strategy, :terminality


  def self.search search, use_fuzzy_search

    puts "SEARCH = #{search}"
    # unless params[:search].blank?
    unless search.blank?
      @results = Hash.new

      # exclude_columns = ['id', 'image_url', 'created_at', 'updated_at']
      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'cost']
      columns = Card.attribute_names - exclude_columns

      @cards = []

      # col = "name"
      columns.each do |col|
        if use_fuzzy_search
          cards = Card.send("find_by_fuzzy_#{col}", search)
        else
          cards = Card.where("#{col} LIKE ?","%#{search}%")
        end

        cards.each do |result|
          # get the matching term
        end

        @results[col]  = cards unless cards.empty?
        # @results[col]  = {card: cards, matched_term: cards.read_attribute[col] }
      end

      # card,send("method_name")

      # Output results for testing
      puts ">>>>>>>Results #{@results}"

      @results.each do |k,v|
        v.each do |card|
          p "Card = #{card[:name]} in #{k}"
          card.each do |match|
            puts "Matched to query #{match}"
          end

          # puts <br>
        end
      end
      #>>>>>>>>>>>>>>>>>>>>>>>>>

    else
      @results = {}
    end
  end
end
