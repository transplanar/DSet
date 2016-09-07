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
      columns = get_relevant_columns()

      unless is_numeric?(search_str)
        search_queries = search_str.split
      else
        search_queries = [search_str.to_s]
      end

      # TODO refactor to single-term query parsing
      # sql_hash = regex_test(search_queries, columns, slot)
      # card_results = regex_test(search_queries, columns, slot)
      results = regex_test(search_queries, columns, slot)

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

  def self.regex_test user_input, columns, slot
    results_hash = Hash.new

    # if user_input.length == 1
    #   letter_regex = get_regex_from_partial_string(user_input.first)
    #
    #   columns.each do |col|
    #     test_search = Card.send("_#{col}", letter_regex)
    #
    #     unless test_search.blank?
    #       results_hash[col] = test_search.to_sql
    #     end
    #   end
    # else
      term_arr = []
      index = 0

      user_input.each do |query|
        term_arr << get_regex_from_partial_string(query)
      end

      results_hash = test_scope(term_arr, columns)
    # end

    return results_hash
  end

  private

  def self.get_regex_from_partial_string arr
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

  def self.test_scope terms, columns, matched_hsh=Hash.new, term_index=0
    matched_hsh[:cards] ||= Card.all

    if term_index === terms.length
      return matched_hsh
    else
      hits = []
      results = []

      if matched_hsh[:col_matches]
        matched_hsh[:col_matches].each do |m|
          columns.delete(m)
        end
      end

      columns.each do |col|
        col_matches = []
        term_matches = []
        card_match_arr = matched_hsh[:cards].send("_#{col}", terms[term_index])

        unless card_match_arr.empty?
          if !matched_hsh[:col_matches]
            col_matches << "#{col}"
          elsif !col_matches.include? col
          # else
            col_matches << matched_hsh[:col_matches] << [col]
          end

          # FIXME returns correct cards, but too many term matches
          # FIXME does not show "alt-VP" strategy for Gardens
          # FIXME detect depth to support 2+ chained queries

          if matched_hsh[:term_matches]
            term_matches = matched_hsh[:term_matches]
          end

          # Is loop needed here?
          card_match_arr.each do |card|
            if !is_numeric?(card["#{col}"])
              multi_desc = card["#{col}"].split(', ')

              if multi_desc.length > 1
                multi_desc.each do |d|
                  if d.include? terms[term_index]
                    term_matches << d
                  end
                end
              else
                term_matches << card["#{col}"]
              end
            else
              term_matches << card["#{col}"]
            end
          end

          term_matches.uniq!

          hits << {cards: card_match_arr, col_matches: col_matches, term_matches: term_matches}
        end
      end

      if hits.blank?
        return nil
      else
        term_index = term_index + 1

        hits.each do |hit|
          results << test_scope(terms, columns, hit, term_index)
        end
      end
    end

    return results.compact
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
