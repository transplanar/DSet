class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots

  scope :_name, -> (regex){Card.where("name ILIKE ?", regex)}
  scope :_types, -> (regex){Card.where("types ILIKE ?", regex)}
  scope :_category, -> (regex){Card.where("category ILIKE ?", regex)}
  scope :_cost, -> (regex){Card.where("cost = ?", regex) }
  scope :_expansion, -> (regex){Card.where("expansion ILIKE ?", regex)}
  scope :_strategy, -> (regex){Card.where("strategy ILIKE ?", regex)}
  scope :_terminality, -> (regex){Card.where("terminality ILIKE ?", regex)}

  single_term_columns = ["cost"]

  def self.search search_str, slot
    unless search_str.blank?
      unless is_numeric?(search_str)
        search_queries = search_str.split
      else
        search_queries = [search_str.to_s]
      end

      results = regex_test(search_queries, slot)
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
    end

    return results
  end

  def self.regex_test user_input, slot
    term_arr = []

    user_input.each do |query|
      unless is_numeric?(query)
        term_arr << format_query_for_scope(query)
      else
        term_arr << query
      end
    end

    results = get_matches(term_arr)

    return results
  end

  private

  def self.format_query_for_scope arr
    regex = ""
    letters = arr.chars

    letters.each do |letter|
      if letter === letters.first
        regex << "#{letter}"
      else
        regex <<  "%#{letter}"
      end
    end

    regex = "%"+regex+'%'

    return regex
  end

  # REVIEW can this be below get_card_subset?
  # TODO parse multi-word categories, clean query to basic string
  # def self.format_term string, character
  def self.format_term string, sub_string
    new_string = ''

    # if is_numeric? character
    if is_numeric? sub_string
      # character = character.to_s
      sub_string = sub_string.to_s
    end

    # character = character.gsub('%','')
    sub_string = sub_string.gsub('%','')

    # puts "Character length #{character.length}"
    if is_numeric? string
      string = "#{string}"
    end

    sub_string.split.each do |char|
      index = string.downcase.index(char)

      # formatted_term = "<b>#{string[index]}</b>"
      formatted_term = "<span class='matched_letter_highlight'>#{string[index]}</span>"
      new_string << string.gsub(string[index], formatted_term)
    end

    return new_string

    # index = string.downcase.index(character)
    #
    # # formatted_term = "<b>#{string[index]}</b>"
    # formatted_term = "<span class='matched_letter_highlight'>#{string[index]}</span>"
    # string.gsub(string[index], formatted_term)
  end

  def self.get_card_subset query, card_match_data, columns = []
    results = []
    exclude_columns = []

    if card_match_data.empty?
      card_set = Card.all
    else
      card_set = Card.where(id: card_match_data.map{|e| e[:card].id})
    end

    columns.each do |col|
      if col=='cost' && is_numeric?(query)
        cards_from_scope = card_set.send("_cost", query)
      elsif !is_numeric?(query) && col != 'cost'
        cards_from_scope = card_set.send("_#{col}", query)
      end

      unless cards_from_scope.nil?
        cards_from_scope.each do |card|
          if card_match_data.empty?
            term_formatted = format_term(card["#{col}"], query)
            # results << {card: card, columns: [col], term_matches: [card["#{col}"]]}
            results << {card: card, columns: [col], term_matches: [term_formatted]}
          else
            existing_card = card_match_data.select{|e| e[:card] == card}.first
            existing_card[:columns] = existing_card[:columns] | [col]
            term_formatted = format_term(card["#{col}"], query)
            # existing_card[:term_matches] = existing_card[:term_matches] | [card["#{col}"]]
            existing_card[:term_matches] = existing_card[:term_matches] | [term_formatted]

            results << existing_card
          end

          exclude_columns << col
        end
      end
    end

    return [results, exclude_columns]
  end

  def self.get_matches queries
    results = []
    card_match_data = []
    columns = get_relevant_columns()

    queries.each do |query|
      card_match_data, exclude_columns = get_card_subset(query, card_match_data, columns)

      unless query == query.last
        columns = columns - exclude_columns
      end
    end

    results_by_columns = card_match_data.group_by{|elem| elem[:columns]}.sort_by{|k,v| k}

    return results_by_columns
  end

  def self.query_to_regex query
    clean_query = query.gsub(/[\[\]]/,"")
    return /#{clean_query}/i
  end

  def self.isolate_term term_string, query
    unless is_numeric? term_string
      test = term_string.split(", ")

      if test.length > 1
        regex = query_to_regex(query)

        test.each do |word|
          if regex.match(word)
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
    new_str = obj.to_s.gsub('%','')
    new_str.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  # FIXME requires refactor
  # def self.save_cards_to_slot search_str, results, slot
  #   cards_to_slot = []
  #
  #   results.each do |k, card|
  #     card.each do |c|
  #       cards_to_slot << c
  #     end
  #   end
  #
  #   cards_to_slot.uniq!
  #
  #   slot.cards = cards_to_slot
  #   slot.update_attribute(:queries, search_str)
  # end
end
