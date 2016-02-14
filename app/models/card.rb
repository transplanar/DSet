class Card < ActiveRecord::Base
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
      columns = get_relevant_columns()

      unless is_numeric?(search)
        search_queries = search.split(', ')
      else
        search_queries = [search.to_s]
      end

      # Search for matches against first search term
      query = search_queries.first
      match_columns = Hash.new

      sql_hash = Hash.new

      columns.each do |col|
        test_search = Card.send( "_#{col}", query )

        unless test_search.blank?
          unless slot.sql_prepend.blank?
            sql_hash[col] = slot.sql_prepend + " AND "+ test_search.to_sql.gsub(/.*?(?=\()/im, "")
          else
            sql_hash[col] = Card.send( "_#{col}", query).to_sql
          end
        end
      end

      multisearch = search_queries.count > 1

      if multisearch
        multi_result = Hash.new

        query_2 = search_queries.second
        match_columns_2 = Hash.new

        # Find columns with matching terms
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

      # Use appropriate hash based on number of chained queries
      results = Hash.new

      unless multisearch
        _results = sql_hash
      else
        _results = multi_result
      end

      # Perform search
      _results.each do |heading, sql|
        cards = Card.find_by_sql(sql)

        unless cards.blank?
          results[heading] = cards
        end
      end

      # Get the exact terms matched by search
      matched_terms = Hash.new

      # FIXME this does not display all the correct terms for multi-keyword categories
      columns.each do |col|
        results.each do |k, card|
          card.each do |c|
            unless col == 'name'
              if col == "cost"
                split_terms = [c["#{col}"].to_s]
              else
                split_terms = c["#{col}"].split(', ')
              end

              split_terms.each do |term|
                search_queries.each do |query|
                  if term.downcase.include? query.downcase
                    matched_terms[col] = term
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
      # If no search query is given, make everything blank
      unless slot.sql_prepend.blank?
        cards_to_slot = []

        cards = Card.find_by_sql(slot.sql_prepend)

        cards_to_slot.uniq!

        slot.cards = cards
        slot.update_attribute(:queries, search)
      else
        slot.cards = Card.all
      end

      results = {}
      matched_terms = {}
    end

    return [results, matched_terms]
  end

  private

  def self.get_relevant_columns
    exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
    Card.attribute_names - exclude_columns
  end

  def self.is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end
