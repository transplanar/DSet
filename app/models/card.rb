class Card < ActiveRecord::Base
  fuzzily_searchable :name, :types, :category, :expansion, :strategy, :terminality

  scope :_name, -> (name) {where("name like ?", "%#{name}%")}
  scope :_types, -> (types) {where("types like ?", "%#{types}%")}
  scope :_category, -> (category) {where("category like ?", "%#{category}%")}
  scope :_cost, -> (cost) {where("cost like ?", "%#{cost}%")}
  scope :_expansion, -> (expansion) {where("expansion like ?", "%#{expansion}%")}
  scope :_strategy, -> (strategy) {where("strategy like ?", "%#{strategy}%")}
  scope :_terminality, -> (terminality) {where("terminality like ?", "%#{terminality}%")}

  def self.search search
    unless search.blank?
      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
      columns = Card.attribute_names - exclude_columns

      unless is_numeric?(search)
        search_queries = search.split(', ')
      else
        search_queries = [search.to_s]
      end

      @multisearch = search_queries.count > 1

      sql_hash = Hash.new
      match_columns = Hash.new
      multi_result = Hash.new
      @results = Hash.new

      query = search_queries.first

      # Get initial term for each search branch
      columns.each do |col|
        unless Card.send( "_#{col}", query ).blank?
          match_columns[col] = query
        end
      end

      match_columns.each do |col, query|
        sql_hash[col] = Card.send( "_#{col}", query).to_sql
      end

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

      _results.each do |k, v|
        cards = Card.find_by_sql(v)

        unless cards.blank?
          @results[k] = cards
        end
      end
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
