class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots

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
    if is_numeric?(queries_string)
      [queries_string.to_s]
    else
      queries_string.split
    end
  end

  def self.format_for_regex(queries_array)
    subqueries = []

    queries_array.each do |query|
      subqueries << (is_numeric?(query) ? query : string_to_fuzzy_regex(query))
    end

    subqueries
  end

  def self.string_to_fuzzy_regex(arr)
    regex = ''
    letters = arr.chars

    letters.each do |letter|
      regex << letter == letters.first ? letter.to_s : "%#{letter}"
    end

    "%#{regex}%"
  end

  def self.get_matches(subqueries)
    match_data = []
    columns = relevant_columns

    subqueries.each do |query|
      match_data, matched_columns =
        get_card_subset(query, match_data, columns)

      columns -= matched_columns unless query == subqueries.last
    end

    return [] if match_data.empty?
    p "Match data #{match_data}"

    # FIXME: Improperly storing data.
    # Needs to be a single hash, not array of hashes
    match_data.group_by { |elem| elem[:columns] }.sort_by { |k, _| k }
  end

  private_class_method def self.get_card_subset(query, match_data, columns = [])
    # TODO: Convert results to hash instead of multidimensional array
    results = []
    matched_columns = []

    card_set =
      (match_data.empty? ?
        Card.all : Card.where(id: match_data.map { |e| e[:card].id }))

    columns.each do |col|
      next if col == 'cost' && !is_numeric?(query)

      matches = matches_from_column(query, card_set, match_data, col)
      # p "Matches #{matches}"

      if(matches.any?)
          matched_columns << col
          results = results | matches
      end
    end

    [results, matched_columns]

    # NOTE: Working version
    # results = []
    # matched_columns = []
    #
    #   matches_from_scope = card_set.send("_#{col}", query)
    #
    #   # next if matches_from_scope.nil?
    #
    #   matches_from_scope.each do |card|
    #     if match_data.empty?
    #       results <<
    #         { card: card, columns: [col], term_matches: [card[col.to_s]] }
    #     else
    #       existing_card = match_data.select { |e| e[:card] == card }.first
    #       existing_card[:columns] << col
    #       existing_card[:term_matches] << card[col.to_s]
    #
    #       results << existing_card
    #     end
    #
    #     matched_columns << col
    #   end
    # end
    #
    # [results, matched_columns]
  end

  private_class_method def self.matches_from_column(query, card_set, match_data, column)
    results = []

    matches_from_scope = card_set.send("_#{column}", query)

    return [] if matches_from_scope.nil?

    matches_from_scope.each do |card|
      if match_data.empty?
        results <<
          { card: card, columns: [column], term_matches: [card[column.to_s]] }
      else
        existing_card = match_data.select { |e| e[:card] == card }.first
        existing_card[:columns] << column
        existing_card[:term_matches] << card[column.to_s]

        # existing_card = card_set.select { |e| e[:card] == card }.first
        # existing_card[:columns] = existing_card[:columns] | [col]
        # existing_card[:term_matches] =
        #   existing_card[:term_matches] | [card[col.to_s]]

        results << existing_card
      end

      # matched_columns << column
    end

    return results

    # [results, matched_columns]
  end


    # results = []
    # matched_columns = []
    # matches_from_scope = card_set.send("_#{column}", query)
    #
    # # next if matches_from_scope.nil?
    # return [results, matched_columns] if matches_from_scope.nil?
    #
    # matches_from_scope.each do |card|
    #   if match_data.empty?
    #     results <<
    #       { card: card, columns: [column], term_matches: [card[column.to_s]] }
    #   else
    #     existing_card = match_data.select { |e| e[:card] == card }.first
    #     existing_card[:columns] << column
    #     existing_card[:term_matches] << card[column.to_s]
    #
    #     results << existing_card
    #   end
    #
    #   matched_columns << column
    # end
    #
    # [results, matched_columns]
  # end

  # end

  # def self.filter_by_column(query, card_set, columns)
  #   results = []
  #   matched_columns = []
  #
  #   columns.each do |col|
  #     # matches_from_scope = fetch_matches_from_scope(query, card_set, col)
  #     if col == 'cost' && is_numeric?(query)
  #       matches_from_scope = card_set.send('_cost', query)
  #     elsif !is_numeric?(query) && col != 'cost'
  #       matches_from_scope = card_set.send("_#{col}", query)
  #     end
  #
  #     next if matches_from_scope.nil?
  #
  #     matches_from_scope.each do |card|
  #       # if match_data.empty?
  #       if card_set.empty?
  #         results <<
  #           { card: card, columns: [col], term_matches: [card[col.to_s]] }
  #       else
  #         # existing_card = match_data.select { |e| e[:card] == card }.first
  #         existing_card = card_set.select { |e| e[:card] == card }.first
  #         existing_card[:columns] = existing_card[:columns] | [col]
  #         existing_card[:term_matches] =
  #           existing_card[:term_matches] | [card[col.to_s]]
  #
  #         results << existing_card
  #       end
  #
  #       matched_columns << col
  #     end
  #   end
  #
  #   [results, matched_columns]
  # end

  # def self.fetch_matches_from_scope(query, card_set, column)
  #   matches_from_scope = []
  #   # (is_numeric?(query) && column == 'cost') ?
  #     # card_set.send('_cost', query) : card_set.send(column.to_s, query)
  #
  #   if column == 'cost' && is_numeric?(query)
  #     matches_from_scope = card_set.send('_cost', query)
  #   elsif !is_numeric?(query) && column != 'cost'
  #     matches_from_scope = card_set.send(column.to_s, query)
  #   end
  #
  #   matches_from_scope
  # end

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

  def self.relevant_columns
    # matched_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
    matched_columns = %w[id image_url created_at updated_at slot_id]
    Card.attribute_names - matched_columns
  end

  def self.is_numeric?(obj)
    new_str = obj.to_s.gsub('%','')
    new_str.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end
