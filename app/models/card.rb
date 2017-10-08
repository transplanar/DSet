
require 'pp'

class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots
  has_many :card_keywords

  scope :_name, ->(regex) { Card.where('name ILIKE ?', regex) }
  scope :_types, ->(regex) { Card.where('types ILIKE ?', regex) }
  scope :_category, ->(regex) { Card.where('category ILIKE ?', regex) }
  scope :_cost, ->(regex) { Card.where('cost = ?', regex)  }
  scope :_expansion, ->(regex) { Card.where('expansion ILIKE ?', regex) }
  scope :_strategy, ->(regex) { Card.where('strategy ILIKE ?', regex) }
  scope :_terminality, ->(regex) { Card.where('terminality ILIKE ?', regex) }

  # TODO: fix to assign to slot
  def self.search(queries_string, slot)
    return [] if queries_string.blank?

    queries_array = queries_to_array(queries_string)
    subqueries = format_for_regex(queries_array)
    get_matches(subqueries)
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

  private_class_method def self.string_to_fuzzy_regex(arr)
    regex = ''
    letters = arr.chars

    letters.each do |letter|
      regex << letter == letters.first ? letter.to_s : "%#{letter}"
    end

    "%#{regex}%"
  end

  private_class_method def self.get_matches(subqueries)
    match_data = []
    columns = relevant_columns

    subqueries.each do |query|
      match_data, matched_columns =
        get_card_subset(query, match_data, columns)

      columns -= matched_columns unless query == subqueries.last
    end

    return [] if match_data.empty?

    match_data.group_by { |elem| elem[:columns] }.sort
  end

  private_class_method def self.get_card_subset(query, match_data, columns = [])
    results = []
    matched_columns = []

    card_set = (match_data.empty? ? Card.all : to_active_record(match_data))

    columns.each do |col|
      next if col == 'cost' && !numeric?(query)

      matches = matches_from_column(query, card_set, match_data, col)

      next if matches.empty?

      matched_columns << col
      results |= matches
    end

    [results, matched_columns]
  end

  private_class_method def self.to_active_record(match_data)
    Card.where(id: match_data.map { |e| e[:card].id })
  end

  private_class_method def self.matches_from_column(query, card_set, match_data, column)
    matches_from_scope = card_set.send("_#{column}", query)

    return [] if matches_from_scope.nil?

    sort_matches(matches_from_scope, match_data, column)
  end

  private_class_method def self.sort_matches(matches_from_scope, match_data, column)
    results = []

    matches_from_scope.each do |card|
      if match_data.empty?
        results << new_result_hash(column, card)
      else
        results << update_result_hash(column, card, match_data)
      end
    end

    results
  end

  private_class_method def self.new_result_hash(column, card)
    {
      columns: [column],
      card: card,
      term_matches: [card[column.to_s]]
    }
  end

  private_class_method def self.update_result_hash(column, card, match_data)
    existing_card = match_data.select { |e| e[:card] == card }.first
    existing_card[:columns] << column
    existing_card[:term_matches] << card[column.to_s]

    existing_card
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

  private_class_method def self.relevant_columns
    matched_columns = %w[id image_url created_at updated_at slot_id]
    Card.attribute_names - matched_columns
  end

  private_class_method def self.numeric?(str)
    str.to_s.delete('%').match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil
  end
end
