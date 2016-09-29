class Card < ActiveRecord::Base
  has_and_belongs_to_many :slots

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
    results_hash = Hash.new

    term_arr = []

    user_input.each do |query|
      term_arr << format_query_for_scope(query)
    end

    results_hash = get_matches(term_arr)
    # results = format_results(results_hash)

    # TODO test
    results = []
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

  def self.get_matches queries
    columns = get_relevant_columns()
    results_arr = []
    sql_string_data = []
    matches = []

    # Create array of sql statements for each possible query/column combination
    queries.each_with_index do |query, index|
      columns.each do |col|
        if !sql_string_data[index]
          sql_string_data[index] = []
        end

        matches_in_column = []
        cards_from_scope = Card.send("_#{col}", query)

        unless cards_from_scope.empty?
          if query == queries.first
            sql = cards_from_scope.to_sql
          else
            sql = cards_from_scope.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", " AND ")
          end

          # sql_string_data[index] << { sql: sql, columns: [col], cards: cards_from_scope}
          sql_string_data[index] << { sql: sql, columns: [col]}
        end
      end
    end

    puts "performing concatenation"
    concat = []

    # concat = sql_string_data.map do |memo, data|
    # initial = {sql: '', columns: [], cards: Card.none}
    # initial = {sql: '', columns: []}
    #
    # concat = sql_string_data.reduce(initial) do |memo, elem|
    #   puts "test #{memo}"
    #   puts "elem #{elem}"
    #
    #   elem.each do |e|
    #     memo[:sql] = memo[:sql] + e[:sql]
    #     memo[:columns] = memo[:columns] + e[:columns]
    #   end
    #   # memo[:sql] = memo[:sql] + elem[:sql]
    #   # memo[:columns] = memo[:columns] + elem[:columns]
    #   # memo[:cards] = memo[:cards] | elem[:cards]
    #   # {
    #   #   sql: memo[:sql] + elem[:sql],
    #   #   columns: memo[:columns] + elem[:columns],
    #   #   matches: memo[:cards] | elem[:cards]
    #   # }
    # end

    init = {sql: '', columns: [], cards: Card.none}

    # TODO create chain and put into .send method
    # sql_string_data.reduce(init) do |memo, elem|
    sql_string_data.each do |elem|
      # {sql: elem[:sql] + memo[:sql], columns: elem[:columns] + memo[:columns]}
      # elem.each do |e|
      concat << elem.reduce(init) do |memo, e|
        {
          sql: memo[:sql] + e[:sql],
          columns: memo[:columns] + e[:columns],
        }
      end
      # puts "elem #{elem}"
      # memo[:sql] = memo[:sql] + elem[:sql]
    end
    puts "concat method 1 #{concat}"
    concat1 = concat

    concat = []

    # FIXME works for two terms. Make it work for infinite!
    sql_string_data[0].each_with_index do |e1, i|
      sql_string_data[1].each_with_index do |e2, j|
        concat << {
          sql: sql_string_data[0][i][:sql] + sql_string_data[1][j][:sql],
          columns: sql_string_data[0][i][:columns] + sql_string_data[1][j][:columns],
          # matches: sql_string_data[0][i][:cards] | sql_string_data[1][j][:cards]
        }
      end
    end
    concat2 = concat

    puts "concat method 2 #{concat}"


    results = Hash.new

    concat.each do |test|
      cards_from_sql = Card.find_by_sql(test[:sql])

      if !cards_from_sql.empty?
        cards_from_sql.each do |card|
          card_terms = []
          test[:columns].each do |col|
            card_terms << card["#{col}"]
          end

          if results["#{test[:columns]}"]
            results["#{test[:columns]}"] << {card: card, terms:card_terms}
          else
            results["#{test[:columns]}"] = [{card: card, terms:card_terms}]
          end
        end
      end
    end

    # puts "results #{results}"

    return results
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
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
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
