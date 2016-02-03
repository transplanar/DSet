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

  # def self.search search
  def self.search search, slot
    unless search.blank?
      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
      columns = Card.attribute_names - exclude_columns

      unless is_numeric?(search)
        search_queries = search.split(', ')
      else
        search_queries = [search.to_s]
      end

      multisearch = search_queries.count > 1

      sql_hash = Hash.new
      match_columns = Hash.new
      multi_result = Hash.new
      results = Hash.new

      matched_terms = []

      query = search_queries.first

      columns.each do |col|
        unless Card.send( "_#{col}", query ).blank?
          match_columns[col] = query
        end
      end

      match_columns.each do |col, query|
        sql_hash[col] = Card.send( "_#{col}", query).to_sql
      end

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

      columns.each do |col|
        results.each do |k, card|
          card.each do |c|
            unless col == "cost"
              split_terms = c["#{col}"].split(',')
            else
              split_terms = [c["#{col}"].to_s]
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

      # REVIEW is this correct?
      cards_to_slot = []

      results.each do |k, card|
        card.each do |c|
          cards_to_slot << c
        end
      end

      cards_to_slot.uniq!

      slot.cards = cards_to_slot
      # slot.card_collection_sql = results
    else
      results = {}
      matched_terms = {}
      matched_cards = []
    end

    slot.cards.uniq!
    # slot.cards = slot.cards.uniq

    slot.cards.each do |k|
      puts "CARD = #{k.name}"
    end

    # return [results, matched_terms, multisearch]
    return [results, matched_terms]
  end

   def self.is_numeric?(obj)
      obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
   end
end
