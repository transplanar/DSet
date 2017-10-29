
# require "awesome_print"

class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots
  has_many :card_keywords

  # scope :_name, ->(regex) { Card.where('name ILIKE ?', regex) }
  # scope :_types, ->(regex) { Card.where('types ILIKE ?', regex) }
  # scope :_category, ->(regex) { Card.where('category ILIKE ?', regex) }
  # scope :_cost, ->(regex) { Card.where('cost = ?', regex)  }
  # scope :_expansion, ->(regex) { Card.where('expansion ILIKE ?', regex) }
  # scope :_strategy, ->(regex) { Card.where('strategy ILIKE ?', regex) }
  # scope :_terminality, ->(regex) { Card.where('terminality ILIKE ?', regex) }

  # TODO: fix to assign to slot
  def self.search(queries_string, slot)
    return [] if queries_string.blank?

    queries_array = queries_to_array(queries_string)
    subqueries = format_for_regex(queries_array)
    matches = get_matches(subqueries)
    # convert_to_match_hash(matches)
# (query, match_data, columns = [])
    # get_card_subset(subqueries.first, [], [])
  end

  def self.queries_to_array(queries_string)
    if numeric?(queries_string)
      [queries_string.to_s]
    else
      queries_string.split
    end
  end

  # TODO failing to bookend characters with %
  private_class_method def self.format_for_regex(queries_array)
    subqueries = []

    queries_array.each do |query|
      subqueries << (numeric?(query) ? query : string_to_fuzzy_regex(query))
    end

    subqueries
  end

  private_class_method def self.string_to_fuzzy_regex(str)
    regex = ''
    letters = str.chars

    letters.each do |letter|
      regex << (letter == letters.first ? letter.to_s : "%#{letter}")
    end

    "%#{regex}%"
  end

  private_class_method def self.get_matches(subqueries)
    match_data = {}

    subqueries.each do |query|
      match_data =
        get_card_subset(query, match_data)

      # columns -= matched_categories unless query == subqueries.last
    end

    return [] if match_data.empty?

    match_data.group_by { |elem| elem[:columns] }.sort
  end

  # Match data is a hash of query, card, column

  private_class_method def self.get_card_subset(query, match_data)
    # card_set = (match_data.empty? ? Card.all : to_active_record(match_data))
    if(match_data.empty?)
      card_set = Card.all
      matched_columns = []
    else
      card_set = Card.where(name: match_data.keys)
      matched_columns = match_data.pluck(:columns)
    end
    
    card_set = (match_data.empty? ? Card.all : Card.where(name: match_data.keys))
    # columns = []
    matched_card_ids = card_set.pluck(:id)
    
    if(numeric?(query))
      matched_cards = card_set.where(cost: query)

      # TODO move this to a separate method
      matched_cards.each do |card|
        if (match_data[card.name])
          match_data[card.name][:columns] << 'cost'
          match_data[card.name][:queries] << query
        else
          match_data[card.name] = {} 
          match_data[card.name][:columns] = ['cost']
          match_data[card.name][:queries] = [query]
        end
      end
      
      p "NUMERIC"
      p "RAW MATCH DATA #{match_data}"
      p "KEYS #{match_data.keys}"
    else
      # NOTE: Must associate each keyword/term/category match as single data object
      # Field being compared against
      # matched_columns = match_data.empty? ? [] : match_data.pluck(:columns)
      # card_subset = Card.where(name: match_data.keys)
      # matched_card_ids = match_data.pluck(:card)
      
      keyword_set = CardKeyword.where(CardKeyword.arel_table[:card_id].in card_set.pluck(:id))
                              .where(CardKeyword.arel_table[:category].not_in matched_columns)
                              .distinct
      
      keyword_matches = keyword_set.where('name ILIKE ?', query).distinct
      # matched_cards = keyword_matches.pluck(:card)
      
      keyword_matches.each do |kw|
        if (match_data[kw.card.name])
          match_data[kw.card.name][:columns] << kw.category
          # match_data[kw.card.name][:queries] << query
          match_data[kw.card.name][:terms] << kw.name
        else
          match_data[kw.card.name] = {} 
          match_data[kw.card.name][:columns] = [kw.category]
          # match_data[kw.card.name][:queries] = [query]
          match_data[kw.card.name][:terms] = [kw.name]
        end
      end
      
      p "ALPHA"
      p "RAW MATCH DATA #{match_data}"
      p "KEYS #{match_data.keys}"
      
      # matched_cards.each do |card|
      #   if (match_data[card.name])
      #     match_data[card.name][:columns] << 'cost'
      #     match_data[card.name][:queries] << query
      #   else
      #     match_data[card.name] = {} 
      #     match_data[card.name][:columns] = ['cost']
      #     match_data[card.name][:queries] = [query]
      #   end
      # end
      
      # matched_categories = keyword_matches.pluck(:category).uniq!
      # card_ids = keyword_matches.pluck(:card_id)
      # matched_cards = Card.where(Card.arel_table[:id].in card_ids)
      
      # p "---CARDS #{matched_cards.pluck(:name)}"    
      # p "---KEYWORDS #{keyword_matches.pluck(:name)}"    

      # keyword_matches = CardKeyword.where('name ILIKE ?', query).distinct
      
      # Array of categories already matched (to prevent duplicates)
      
      
      # keyword_matches.each do |keyword|
      #   card = Card.where(id: keyword.card_id)
        
        
      # end
      
      # card_ids = keyword_matches.pluck(:card_id)
      # matched_cards = card_set.where(id: card_ids)
      
      # match_data.empty? new_result(matched_categories, matched_cards) 
      #                   : update_result(matched_categories, matched_cards);
    end

    [results, matched_categories]
  end
  
  # private_class_method def self.match_data_to_active_record(data)
  #   CardKeyword.where(id: match_data.map {|e| e[:] })
  # end

  # private_class_method def self.to_active_record(match_data)
  #   Card.where(id: match_data.keys)
  # end

  # private_class_method def self.new_result(cards, categories)
  #   results = {}
  #   cards.each do |card|
  #     results[card.name] = {
        
  #     }
  #   end
  # end

  # private_class_method def self.update_result(column, card, match_data)
  #   existing_card = match_data.select { |e| e[:card] == card }.first
  #   existing_card[:columns] << column
  #   existing_card[:term_matches] << card[column.to_s]

  #   existing_card
  # end

  private_class_method def self.query_to_regex(query)
    '/' + query.gsub(/[\[\]]/, '') + '/i'
  end

  private_class_method def self.isolate_term(term_string, query)
    return if numeric?(term_string)

    test = term_string.split(', ')

    return if test.empty?

    regex = query_to_regex(query)

    test.each do |word|
      return word if regex.match(word)
    end
  end

  private_class_method def self.format_results(hash)
    groups = hash.group_by { |e| e[:columns] }

    groups.each_key do |key|
      groups[key.join(' < ')] = groups.delete key
    end
  end

  private_class_method def self.convert_to_match_hash(match_array)
    match_hash = {}

    match_array.each do |k, v|
      match_hash.store(k.map(&:capitalize).join(', '), v)
    end

    match_hash
  end

  private_class_method def self.relevant_columns
    matched_categories = %w[id image_url created_at updated_at slot_id]
    Card.attribute_names - matched_categories
  end

  private_class_method def self.numeric?(str)
    str.to_s.delete('%').match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil
  end
end
