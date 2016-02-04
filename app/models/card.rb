class Card < ActiveRecord::Base
  fuzzily_searchable :name, :types, :category, :expansion, :strategy, :terminality
  has_and_belongs_to_many :slots

  scope :_name, -> (name) {where("name like ?", "%#{name}%")}
  scope :_types, -> (types) {where("types like ?", "%#{types}%")}
  scope :_category, -> (category) {where("category like ?", "%#{category}%")}
  scope :_cost, -> (cost) {where("cost like ?", "%#{cost}%")}
  scope :_expansion, -> (expansion) {where("expansion like ?", "%#{expansion}%")}
  scope :_strategy, -> (strategy) {where("strategy like ?", "%#{strategy}%")}
  scope :_terminality, -> (terminality) {where("terminality like ?", "%#{terminality}%")}

  # REVIEW split this into separate functions?
  # TODO add optional param to search to allow 'autocomplete' categories
  def self.search search, slot
    unless search.blank?
      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
      columns = Card.attribute_names - exclude_columns

      unless is_numeric?(search)
        search_queries = search.split(', ')
      else
        search_queries = [search.to_s]
      end

      query = search_queries.first
      match_columns = Hash.new

      columns.each do |col|
        unless Card.send( "_#{col}", query ).blank?
          match_columns[col] = query
        end
      end

      sql_hash = Hash.new

      match_columns.each do |col, query|
        sql_hash[col] = Card.send( "_#{col}", query).to_sql
      end

      multi_result = Hash.new

      multisearch = search_queries.count > 1

      # TODO refactor to make recursive, support 2+ queries
      if multisearch
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

      results = Hash.new

      unless multisearch
        _results = sql_hash
      else
        _results = multi_result
      end

      _results.each do |heading, sql|
        cards = Card.find_by_sql(sql)

        unless cards.blank?
          results[heading] = cards
        end
      end

      matched_terms = []

      columns.each do |col|
        results.each do |k, card|
          card.each do |c|
            unless col == 'name'
              if col == "cost"
                split_terms = [c["#{col}"].to_s]
              else
                split_terms = c["#{col}"].split(',')
              end

              split_terms.each do |term|
                search_queries.each do |query|
                  if term.downcase.include? query.downcase
                    matched_terms << "<b>#{col}</b>: #{term}"
                    matched_terms.uniq!
                  end
                end
              end
            end
          end
        end
      end

      cards_to_slot = []

      results.each do |k, card|
        card.each do |c|
          cards_to_slot << c
        end
      end

      cards_to_slot.uniq!

      slot.cards = cards_to_slot
      slot.update_attribute(:queries, search)
    else
      results = {}
      matched_terms = {}
    end

    return [results, matched_terms]
  end

   def self.is_numeric?(obj)
      obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
   end
end
