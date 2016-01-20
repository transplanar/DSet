class Card < ActiveRecord::Base
  # REVIEW How to index your model https://github.com/mezis/fuzzily#usage
  # fuzzily_searchable :name, :cost, :types, :category, :expansion, :strategy, :terminality
  fuzzily_searchable :name, :types, :category, :expansion, :strategy, :terminality


  def self.search search, use_fuzzy_search

    # puts "SEARCH = #{search}"
    # unless params[:search].blank?

    unless search.blank?
      @results = Hash.new

      # exclude_columns = ['id', 'image_url', 'created_at', 'updated_at']
      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'cost']
      columns = Card.attribute_names - exclude_columns

      @cards = []
      @matched_terms = []

      # col = "name"
      columns.each do |col|
        if use_fuzzy_search
          # REVIEW make this more useful by searching across all fields
          cards = Card.send("find_by_fuzzy_#{col}", search)
        else
          cards = Card.where("#{col} LIKE ?","%#{search}%")
        end

        unless cards.empty?
          @results[col]  = cards

          # TODO support parsing of comma-separated, multi-type groupings
          unless col == "name"
            cards.each do |c|
              # puts "TERMS split from card array = #{c["#{col}"].split(',')}"

              split_terms = c["#{col}"].split(',')

              split_terms.each do |term|
                puts "#{term} vs #{search} is #{term.include? search}"
                if term.downcase.include? search.downcase
                  @matched_terms << "#{col}: #{term}"
                  # @matched_terms << term
                  @matched_terms.uniq!
                end
              end

              # puts "TERMS SPLIT = #{@matched_terms[col].split(',')}"
            end
          end

          # REVIEW 1) display search results in order by best match like Atom.io
          puts "Matched terms array #{@matched_terms}"
        end
        # @results[col]  = {card: cards, matched_term: cards.read_attribute[col] }
      end

      # TODO needs to return both of these somehow
      # return @results
      return [@results, @matched_terms]

      # card,send("method_name")

      # Output results for testing
      # puts ">>>>>>>Results #{@results}"
      #
      # @results.each do |k,v|
      #   v.each do |card|
      #     p "Card = #{card[:name]} in #{k}"
      #   end
      # end
      #>>>>>>>>>>>>>>>>>>>>>>>>>

    else
      @results = {}
    end
  end
end
