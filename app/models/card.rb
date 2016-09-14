class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots

  # cards = Arel::Table.new(:cards)

  # scope :_name, -> (name) {Card.where(cards[:name].matches("%#{name}%"))}
  # scope :_types, -> (types) {Card.where(cards[:types].matches("%#{types}%"))}
  # scope :_category, -> (category) {Card.where(cards[:category].matches("%#{category}%"))}
  # scope :_cost, -> (cost) {Card.where(cards[:cost].eq(cost)) }
  # scope :_expansion, -> (expansion) {Card.where(cards[:expansion].matches("%#{expansion}%"))}
  # scope :_strategy, -> (strategy) {Card.where(cards[:strategy].matches("%#{strategy}%"))}
  # scope :_terminality, -> (terminality) {Card.where(cards[:terminality].matches("%#{terminality}%"))}

  scope :_name, -> (regex){Card.where("name REGEXP ?", regex)}
  scope :_types, -> (regex){Card.where("types REGEXP ?", regex)}
  scope :_category, -> (regex){Card.where("category REGEXP ?", regex)}
  scope :_cost, -> (regex){Card.where("cost REGEXP ?", regex)}
  scope :_expansion, -> (regex){Card.where("expansion REGEXP ?", regex)}
  scope :_strategy, -> (regex){Card.where("strategy REGEXP ?", regex)}
  scope :_terminality, -> (regex){Card.where("terminality REGEXP ?", regex)}

  single_term_columns = ["cost"]

  def self.search search_str, slot
    unless search_str.blank?
      # TODO restore prepend functionality?

      unless is_numeric?(search_str)
        search_queries = search_str.split
      else
        search_queries = [search_str.to_s]
      end

      # TODO refactor to single-term query parsing
      # sql_hash = regex_test(search_queries, columns, slot)
      # card_results = regex_test(search_queries, columns, slot)
      # results = regex_test(search_queries, columns, slot)
      results = regex_test(search_queries, slot)

      # results = format_results(card_results)

      # results = generate_results_from_sql (sql_hash)
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
      # matched_terms = {}
    end

    # return [results, matched_terms]
    return results
  end

  # def self.regex_test user_input, columns, slot
  def self.regex_test user_input, slot
    results_hash = Hash.new

    term_arr = []

    user_input.each do |query|
      term_arr << format_query_for_scope(query)
    end

    # results_hash = get_matches(term_arr, columns)
    results_hash = get_matches(term_arr)
    results = format_results(results_hash)

    # return results_hash
    return results
  end

  private

  def self.format_query_for_scope arr
    regex = ""
    letters = arr.chars

    letters.each do |letter|
      if letter === letters.first
        regex << "[#{letter}]"
      else
        regex <<  ".*?[#{letter}]"
      end
    end

    return regex
  end

  # def self.get_matches queries, columns
  def self.get_matches queries
    cards = Card.all
    results_arr = []
    columns = get_relevant_columns()

    queries.each do |query|
      columns.each do |col|
        card_matches = cards.send("_#{col}", query)

        unless card_matches.empty?
          card_matches.each do |card|
            test = results_arr.select { |elem|
              elem[:card].id == card[:id]
            }

            if test.length > 0
              elem = test.first
              elem[:columns] << col
              term = isolate_term(card["#{col}"], query)
              elem[:terms] << term
            else
              term = isolate_term(card["#{col}"], query)
              results_arr << {card: card, columns: [col], terms: [card["#{col}"]]}
            end
          end
        end
      end
    end

    results_arr.delete_if{|elem| elem[:columns].length < queries.length}

    return results_arr
  end

  def self.isolate_term term_string, query
    unless is_numeric? term_string
      test = term_string.split(", ")

      if test.length > 1
        clean_query = query.gsub(/[\[\]]/,"")

        test.each do |word|
          if word.downcase.include? clean_query.downcase
            return word
          end
        end
      end
    end

    return term_string
  end

  def self.format_results hash
    groups = hash.group_by{|e| e[:columns]}

    groups.keys.each do |key|
      groups[key.join(" < ")] = groups.delete key
    end

    return groups
  end

  def self.get_relevant_columns
    exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
    Card.attribute_names - exclude_columns
  end

  def self.is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
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
