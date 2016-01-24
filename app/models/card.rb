class Card < ActiveRecord::Base
  fuzzily_searchable :name, :types, :category, :expansion, :strategy, :terminality


  @@matched_cards = Card.all

  scope :_name, -> (name) {where("name like ?", "#{name}")}
  scope :_types, -> (types) {where("types like ?", "#{types}")}
  scope :_category, -> (category) {where("category like ?", "#{category}")}
  scope :_cost, -> (cost) {where("cost like ?", "#{cost}")}
  scope :_expansion, -> (expansion) {where("expansion like ?", "#{expansion}")}
  scope :_strategy, -> (strategy) {where("strategy like ?", "#{strategy}")}
  scope :_terminality, -> (terminality) {where("terminality like ?", "#{terminality}")}

  def self.search search, use_fuzzy_search
    unless search.blank?

      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at']
      columns = Card.attribute_names - exclude_columns

      search_queries = search.split(', ')

      if search_queries.count > 1
        @results
        @multisearch = true
      else
        @results = Hash.new
        @multisearch = false
      end

      @cards = []
      t_results = []

      @matched_terms = []

      # FIXME breaks in some edge cases
      # 'village, 5' vs '5, village'
      # 'trashing, 4'
      # Appears to have trouble with order of commands, particularly with "trash"
      # Does not display the appropriate results if no results are found using multiple filters
      search_queries.each do |query|
        columns.each do |col|
          if use_fuzzy_search && !is_numeric?(query)
            cards = Card.send("find_by_fuzzy_#{col}", query)
          else
            # if @@matched_cards.nil? || query == search_queries.first
            if query == search_queries.first
              cards = Card.where("#{col} LIKE ?","%#{query}%")
              # XXX scope method = requires specific thing
              # cards = Card.send( "_#{col}", query )
            else
              # XXX special case for if seaching CATEGORY column
              # cards = Card.where("#{col} LIKE ?","%#{query}%")
              # cards ||= @results.where("#{col} LIKE ?","%#{query}%")
              cards = @results.where("#{col} LIKE ?","%#{query}%")
              # puts "NO RESULTS? #{cards.empty?}"
              # cards << @results.where("#{col} LIKE ?","%#{query}%") unless @results.where("#{col} LIKE ?","%#{query}%").blank?
            end
          end

          unless cards.empty?
          # unless cards.blank?
            unless search_queries.count > 1
              @results[col]  = cards
            else
              @results = cards
              # @matched_terms = []
            end

            cards.each do |c|
              unless col == "cost"
                split_terms = c["#{col}"].split(', ')

                split_terms.each do |term|
                  if term.downcase.include? query.downcase
                    @matched_terms << "<b>#{col}</b>: #{term}"
                    @matched_terms.uniq!
                  end
                end
              else
                @matched_terms << "<b>#{col}</b>: #{c["#{col}"]}"
                @matched_terms.uniq!
              end
            end
          end
        end
      end

      # WORKING
      # columns.each do |col|
      #   if use_fuzzy_search && !is_numeric?(search)
      #     cards = Card.send("find_by_fuzzy_#{col}", search)
      #   else
      #     cards = Card.where("#{col} LIKE ?","%#{search}%")
      #   end
      #
      #   unless cards.empty?
      #     @results[col]  = cards
      #
      #     unless col == "name"
      #       cards.each do |c|
      #
      #         split_terms = c["#{col}"].split(',')
      #
      #         split_terms.each do |term|
      #           puts "#{term} vs #{search} is #{term.include? search}"
      #           if term.downcase.include? search.downcase
      #             @matched_terms << "<b>#{col}</b>: #{term}"
      #             # @matched_terms << term
      #             @matched_terms.uniq!
      #           end
      #         end
      #       end
      #     end
      #     puts "Matched terms array #{@matched_terms}"
      #   end
      # end

      # XXX FOR TESTING
      # puts ">>>>>>>Results #{@results}"
      #
      # @results.each do |k,v|
      #   v.each do |card|
      #     p "Card = #{card[:name]} in #{k}"
      #   end
      # end

      # puts "FLATTEN 1x #{@results.flatten(1)}"
      # puts "FLATTEN 2x #{@results.flatten}"
      # puts "TEST #{ @results.select{ |c| c["name"] == query}  } "
      #>>>>>>>>>>>>>>>>>>>>>>>>>

    else
      @results = {}
      @matched_terms = {}
      @@matched_cards = []
    end



    return [@results, @matched_terms, @multisearch]
  end

   def self.is_numeric?(obj)
      obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
   end
end
