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
  def self.search search_str, slot
    unless search_str.blank?
      columns = get_relevant_columns()

      unless is_numeric?(search_str)
        search_queries = search_str.split(', ')
      else
        search_queries = [search_str.to_s]
      end

      sql_hash = generate_sql_hash(search_queries, columns, slot)

      results = generate_results_from_sql (sql_hash)

      matched_terms = get_matching_terms(search_queries, columns, results)

      save_cards_to_slot(search_str, results, slot)
    else
      unless slot.sql_prepend.blank?
        cards = Card.find_by_sql(slot.sql_prepend)

        slot.cards = cards
        slot.update_attribute(:queries, search_str)
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

  def self.generate_sql_hash queries, columns, slot
    query = queries.first

    results_hash = Hash.new
    multi_result = Hash.new

    queries.each do |query|
      if query == queries.first
        columns.each do |col|
          test_search = Card.send( "_#{col}", query )

          unless test_search.blank?
            unless slot.sql_prepend.blank?
              results_hash[col] = slot.sql_prepend + " AND "+ test_search.to_sql.gsub(/.*?(?=\()/im, "")
            else
              results_hash[col] = test_search.to_sql
            end
          end
        end
      elsif query == queries.second
        columns.each do |col|
          results_hash.each do |col_1, sql |
            test_search = sql + " AND " + Card.send( "_#{col}", query).to_sql.gsub(/.*?(?=\()/im, "")

            unless test_search.blank?
              multi_result["#{col_1} > #{col}"] = sql + " AND " + Card.send( "_#{col}", query ).to_sql.gsub(/.*?(?=\()/im, "")
            end
          end
        end
      end
    end

    unless queries.count > 1
      _results = results_hash
    else
      _results = multi_result
    end
    return _results
  end

  # FIXME this does not display all the correct terms for multi-keyword categories

  def self.get_matching_terms search_queries, columns, results
    matches = Hash.new

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
                  matches[col] = term
                end
              end
            end
          end
        end
      end
    end

    return matches
  end

  def self.generate_results_from_sql sql_hash
    results = Hash.new

    sql_hash.each do |heading, sql|
      cards = Card.find_by_sql(sql)

      unless cards.blank?
        results[heading] = cards
      end
    end

    return results
  end

  def self.save_cards_to_slot search_str, results, slot
    cards_to_slot = []

    results.each do |k, card|
      card.each do |c|
        cards_to_slot << c
      end
    end

    cards_to_slot.uniq!

    slot.cards = cards_to_slot
    slot.update_attribute(:queries, search_str)
  end
end
