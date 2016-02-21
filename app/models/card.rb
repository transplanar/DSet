class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots

  cards = Arel::Table.new(:cards)

  scope :_name, -> (name) {Card.where(cards[:name].matches("%#{name}%"))}
  scope :_types, -> (types) {Card.where(cards[:types].matches("%#{types}%"))}
  scope :_category, -> (category) {Card.where(cards[:category].matches("%#{category}%"))}
  scope :_cost, -> (cost) {Card.where(cards[:cost].eq(cost)) }
  scope :_expansion, -> (expansion) {Card.where(cards[:expansion].matches("%#{expansion}%"))}
  scope :_strategy, -> (strategy) {Card.where(cards[:strategy].matches("%#{strategy}%"))}
  scope :_terminality, -> (terminality) {Card.where(cards[:terminality].matches("%#{terminality}%"))}

  single_term_columns = ["cost"]

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

      # TODO If a slot only has 1 card in it, assign that card
      # Move to home#index?

      # if slot.cards.count == 1
        # slot.assign_card(slot.cards.first)
        # post :assign_card, {slot_id: slot.id, id: slot.cards.first.id}
      # end
    else
      unless slot.sql_prepend.blank?
        cards = Card.find_by_sql(slot.sql_prepend)

        slot.cards = cards
        slot.update_attribute(:queries, search_str)
      else
        if slot.cards.blank?
          slot.cards = Card.all
        end
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
          if (col == "cost" && is_numeric?(query)) || col != "cost"

            test_search = Card.send( "_#{col}", query )

            unless test_search.blank?
              unless slot.sql_prepend.blank?
                sql_without_select_prepend = test_search.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", "")

                results_hash[col] = slot.sql_prepend + " AND "+ sql_without_select_prepend
              else
                results_hash[col] = test_search.to_sql
              end
            end
          end
        end
      elsif query == queries.second
        columns.each do |col|
          results_hash.each do |col_1, sql |
            test_search = Card.send( "_#{col}", query)

            unless test_search.blank?
              sql_without_select_prepend = test_search.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", "")

              multi_result["#{col_1} > #{col}"] = sql + " AND " + sql_without_select_prepend
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
      puts "SEARCHING BY SQL #{heading}:#{sql}"
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
