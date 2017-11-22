
# require "awesome_print"

class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots
  has_many :card_keywords

  # TODO: fix to assign to slot
  def self.search(queries_string, slot)
    return [] if queries_string.blank?

    queries_array = queries_to_array(queries_string)
    subqueries = format_for_regex(queries_array)
    matches = get_matches(subqueries)

    matches.group_by { |_, v| v[:columns] }
  end

  def self.queries_to_array(queries_string)
    if numeric?(queries_string)
      [queries_string.to_s]
    else
      queries_string.split
    end
  end

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
      # FIXME Not culling matches that do not match ALL supplied queries
      # get_card_subset(query, match_data)
      result = get_card_subset(query, match_data)

      match_data = result == nil ? match_data : result
    end

    match_data
  end

  # Match data is a hash of query, card, column

  private_class_method def self.get_card_subset(query, match_data)
  # TODO needs new_match_data, cull matches that do not match ALL queries
  # only aggregate fields that need to carry over (columns)
    new_match_data = {}

    if(match_data.empty?)
      card_set = Card.all
      matched_columns = []
    else
      card_set = Card.where(name: match_data.keys)
      matched_columns = match_data.map{|k,v| v[:columns]}.flatten.uniq
    end

    if(numeric?(query))
      matched_cards = card_set.where(cost: query)

      matched_cards.each do |card|
        new_match_data[card.name] = {}
        new_match_data[card.name][:card] = card

        if (match_data[card.name])
          new_match_data[card.name][:columns] = match_data[card.name][:columns] | ['Cost']
          new_match_data[card.name][:terms] = match_data[card.name][:terms] | [query]
        else
          new_match_data[card.name][:columns] = ['Cost']
          new_match_data[card.name][:terms] = [query]
        end
      end
    else
      keyword_set = CardKeyword.where(CardKeyword.arel_table[:card_id].in card_set.pluck(:id) )
                               .where(!(CardKeyword.arel_table[:category].in matched_columns))
                               .distinct

      keyword_matches = keyword_set.where('name ILIKE ?', query).distinct
      
      keyword_matches.each do |kw|
        new_match_data[kw.card.name] = {}
        new_match_data[kw.card.name][:card] = kw.card

        if (match_data[kw.card.name])
          new_match_data[kw.card.name][:columns] = match_data[kw.card.name][:columns] | [kw.category]
          new_match_data[kw.card.name][:terms] = match_data[kw.card.name][:terms] | [kw.name]
        else
          new_match_data[kw.card.name][:columns] = [kw.category]
          new_match_data[kw.card.name][:terms] = [kw.name]
        end
      end
      
      name_matches = card_set.where('name ILIKE ?', query).distinct
      
      name_matches.each do |card|
        new_match_data[card.name] = {}
        new_match_data[card.name][:card] = card

        if (match_data[card.name])
          new_match_data[card.name][:columns] = match_data[card.name][:columns] | ['Name']
          new_match_data[card.name][:terms] = match_data[card.name][:terms] | [query]
        else
          new_match_data[card.name][:columns] = ['Name']
          new_match_data[card.name][:terms] = [query]
        end
      end
      
    end

    new_match_data
  end

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
