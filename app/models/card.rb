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
      # FIXME case for numeric input
      unless is_numeric?(search)
        search_queries = search.split(', ')
      end

      @multisearch = search_queries.count > 1
      puts "MULTISEARCH #{@multisearch}"

      @cards = []
      # t_results = []

      # TODO convert this to a hash with results for each search thread
      # sql_string = ''
      sql_hash = Hash.new
      # sql_params = Hash.new
      sql_chain = Hash.new

      # match_columns = []
      match_columns = Hash.new
      # match_columns = [Hash.new]

      multi_result = Hash.new

      @results = Hash.new

      #NOTE Tests the first query of the query string
      # In multisearch, will be used to produce the first term in the search chain
      query = search_queries.first

      # Get initial term for each search branch
      columns.each do |col|
        unless Card.send( "_#{col}", query ).blank?
          match_columns[col] = query
        end
      end

      # XXX Testing >>>>>>>>>>>>>>>>>>>
      puts "Initial columns #{match_columns}"
      # XXX Testing >>>>>>>>>>>>>>>>>>>

      # Begin compose of first tier of search results
      # match_columns.each_with_index do |(col, query), index|
      match_columns.each do |col, query|
        # if index == 0
          # sql_string = Card.send( "_#{col}", query).to_sql
          sql_hash[col] = Card.send( "_#{col}", query).to_sql
        # else unless @multisearch
        # else
          # sql_string = sql_string + " OR " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
        # end

        # if @multisearch
        #   sql_chain[col] << sql_string
        # end
      end

      # Perform additional steps if you have a multisearch
      # TODO refactor to make recursive, support 2+ queries
      if @multisearch
        query_2 = search_queries.second
        match_columns_2 = Hash.new

        columns.each do |col|
          unless Card.send( "_#{col}", query_2 ).blank?
            match_columns_2[col] = query_2
          end
        end

        sql_hash.each do |k,v|
          match_columns_2.each do |col, query|
            multi_result["#{k} > #{col}"] = v + " AND " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
          end
        end
      end

      unless @multisearch
        _results = sql_hash
      else
        _results = multi_result
      end

      puts "Hash used #{_results}"

      _results.each do |k, v|
        # puts "Key #{k} val #{v}"
        # puts "*Result = #{Card.search(v, false)}"
        # puts "*Result = #{Card.find_by_sql(v)}"
        # Card.find_by_sql(sql_string)

        cards = Card.find_by_sql(v)

        unless cards.blank?
          @results[k] = cards
        end
      end

      #
      # unless sql_string.blank?
      #   @results = Card.find_by_sql(sql_string)
      #
      #   puts "RAW SQL string = #{sql_string}"
      #   puts "Results found #{@results.count}"
      # end

      # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      # XXX TEST to verify storage of column match values
      # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      puts "MATCH COLUMNS"
      # match_columns.each do |match|
      # match_columns.each do |k, v|
      #   puts "#{k}: #{v}"
      # end


    else
      @results = {}
      @matched_terms = {}
      @@matched_cards = []
    end
    #
    # puts "SEARCH RESULTS:"
    # unless @results.blank?
    #   @results.each do |card|
    #     puts card.name
    #   end
    # end
    # puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    return [@results, @matched_terms, @multisearch]
  end

   def self.is_numeric?(obj)
      obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
   end
end
