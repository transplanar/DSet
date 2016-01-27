class Card < ActiveRecord::Base
  fuzzily_searchable :name, :types, :category, :expansion, :strategy, :terminality


  # @@matched_cards = Card.all

  scope :_name, -> (name) {where("name like ?", "%#{name}%")}
  scope :_types, -> (types) {where("types like ?", "%#{types}%")}
  scope :_category, -> (category) {where("category like ?", "%#{category}%")}
  scope :_cost, -> (cost) {where("cost like ?", "%#{cost}%")}
  scope :_expansion, -> (expansion) {where("expansion like ?", "%#{expansion}%")}
  scope :_strategy, -> (strategy) {where("strategy like ?", "%#{strategy}%")}
  scope :_terminality, -> (terminality) {where("terminality like ?", "%#{terminality}%")}

  def self.search search, use_fuzzy_search
    unless search.blank?
      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
      columns = Card.attribute_names - exclude_columns

      # FIXME if you have a query ending in a comma w/o a space, gives bad results
      search_queries = search.split(', ')

      @multisearch = search_queries.count > 1
      puts "MULTISEARCH #{@multisearch}"

      @cards = []
      t_results = []

      sql_string = ''

      # match_columns = []
      match_columns = Hash.new

      search_queries.each do |query|
        columns.each do |col|
          # If a match is found in a given column, add that to array of matched columns
          unless Card.send( "_#{col}", query ).blank?
            # XXX prevent this from being overridden in multi-search
            if match_columns[col].blank?
              match_columns[col] = query
            else
              match_columns[col] = match_columns[col] +", " + query
            end
          end
        end
      end

      # table = Arel::Table.new(:cards)

      puts "MATCH COLUMNS"
      match_columns.each do |k, v|
        puts "#{k}: #{v}"
        # puts "Matched term: #{Card.send( "_#{k}", v).name}"
        # puts "Matched terms:"
        # Card.send( "_#{k}", v).each do |card|
        #   puts card[k]
        # end
      end

      unless @multisearch
        query = search_queries
        # Supports matches across multiple columns
        match_columns.each do |col, query|
          if sql_string.empty?
            sql_string = Card.send( "_#{col}", query).to_sql
          else
            sql_string = sql_string + " OR " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
          end
        end

        unless sql_string.blank?
          @results = Card.find_by_sql(sql_string)

          puts "RAW SQL string = #{sql_string}"
          puts "Results found #{@results.count}"
        end
      else

        # search_queries.each do |q2|
        #   match_columns.first do |col, q1|
        #     # sql_string = Card.send()
        #     Card.send( "_#{col}", q) + " AND "
        #
        #
        #     # if sql_string.empty?
        #     #   sql_string = Card.send( "_#{col.to_s}", query).to_sql
        #     # else
        #     #   sql_string = sql_string + " AND " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
        #     # end
        #   end
        # end

        # unless sql_string.blank?
        #   @results = Card.find_by_sql(sql_string)
        #
        #   puts "RAW SQL string = #{sql_string}"
        #   puts "Results found #{@results.count}"
        # end
      end

      # Restore split results by column as searches may be down many branches?
      # Render results in single SQL statement
      # unless sql_string.blank?
      #   @results = Card.find_by_sql(sql_string)
      #
      #   puts "RAW SQL string = #{sql_string}"
      #   puts "Results found #{@results.count}"
      # end





      # outer = Card._types('action')
      #
      # # outer = Card.all
      # # outer = Card.where(cost: 3)
      #
      # # outer = Card._cost(6)
      # inner = Card._cost(6)
      #
      # # outer = Card.all
      # # outer = outer.from(Arel.sql("(#{inner.to_sql}) as results")).select("*")
      # outer = outer.from(Arel.sql("(#{inner.to_sql})")).select("*")
      #
      # outer.each do |c|
      #   puts c.name
      # end
      # # puts outer
      # # User.where(users[:name].matches("%#{user_name}%"))
      #
      # search_queries.each do |query|
      #   columns.each do |col|
      #     if use_fuzzy_search && !is_numeric?(query)
      #       cards = Card.send("find_by_fuzzy_#{col}", query)
      #     else
      #         # cards = Card.send( "_#{col}", query )
      #
      #         # TODO if results are in multiple category, append "OR" instead of "AND"
      #         # IF a single query produces matches in multiple categories, use OR
      #         if Card.send( "_#{col}", query ).count > 0
      #           if query == search_queries.first
      #             sql_string = Card.send( "_#{col}", query ).to_sql
      #             column_match = column_match + 1
      #             puts "Column match updated to #{column_match}"
      #           else
      #             # Needs to still split by category? Tries to find something that matches in NAME and CATEGORY rather than one or the other
      #             # sql_string = sql_string + " AND " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
      #             if column_match > 0
      #               sql_string = sql_string + " OR " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
      #             else
      #               sql_string = sql_string + " AND " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
      #             end
      #
      #             # XXX template
      #             # SELECT COUNT(*) FROM "cards" WHERE (category LIKE '%village%') AND (cost LIKE '%5%') AND (slot_id LIKE '%5%')
      #             # needed
      #             # SELECT COUNT(*) FROM "cards" WHERE (category LIKE '%village%') AND (cost LIKE '%5%') AND (slot_id LIKE '%5%')
      #           end
      #         end
      #     end
      #
      #   #   unless cards.empty?
      #   #   # unless cards.blank?
      #   #     unless search_queries.count > 1
      #   #       @results[col]  = cards
      #   #     else
      #   #       @results = cards
      #   #       # @matched_terms = []
      #   #     end
      #   #
      #   #     cards.each do |c|
      #   #       unless col == "cost"
      #   #         split_terms = c["#{col}"].split(', ')
      #   #
      #   #         split_terms.each do |term|
      #   #           if term.downcase.include? query.downcase
      #   #             @matched_terms << "<b>#{col}</b>: #{term}"
      #   #             @matched_terms.uniq!
      #   #           end
      #   #         end
      #   #       else
      #   #         @matched_terms << "<b>#{col}</b>: #{c["#{col}"]}"
      #   #         @matched_terms.uniq!
      #   #       end
      #   #     end
      #   #   end
      #   end
      #
      #   # column_match = 0
      # end
      #
      # unless sql_string.blank?
      #   puts "RAW SQL string = #{sql_string}"
      #   @results = Card.find_by_sql(sql_string)
      #   puts "Results found #{@results.count}"
      # end

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
