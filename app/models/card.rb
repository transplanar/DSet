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
    results = format_results(results_hash)

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

    # sql_string_data = Hash.new

    # Create array of sql statements for each possible query/column combination
    queries.each_with_index do |query, index|
      columns.each do |col|
        if !sql_string_data[index]
          sql_string_data[index] = []
        end

        # TODO do gsub here if it is not the first query
        if index == 0
          test = Card.send("_#{col}", query)
          unless test.empty?
            # sql_string_data[index] << test.to_sql
            terms = []
            test.each do |card|
              terms << card["#{col}"]
            end
            # sql_string_data[index] << {sql: test.to_sql, columns: col}
            sql_string_data[index] << {sql: test.to_sql, columns: [col], terms: terms}
          end
        else
          #TODO Detect if a record is in given index position
          test = Card.send("_#{col}", query)
          unless test.empty?
            terms = []
            # sql_string_data[index] << Card.send("_#{col}", query).to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", " AND ")
            # sql_string_data[index] << test.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", " AND ")
            # sql_string_data[index] << {sql: test.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", " AND "), columns: col}
            test.each do |card|
              terms << card["#{col}"]
            end
            # sql_string_data[index] << {sql: test.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", " AND "), columns: col}
            sql_string_data[index] << {sql: test.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", " AND "), columns: [col], terms: terms}
          end
        end
      end
    end

    puts "sql string #{sql_string_data}"

    concat = []

    # FIXME works for two terms. Make it work for infinite!
    # for q in 0..(queries.count-1) do
      # for i in 0..(columns.count-1) do
      # for i in 0..(sql_string_data[0].length) do
      # TODO refactor to use two terms
      sql_string_data[0].each_with_index do |e1, i|
        # for j in 0..(columns.count-1) do
        sql_string_data[1].each_with_index do |e2, j|
          puts "concat i #{i} and j #{j}"
          # concat << ["#{sql_string_data[0][i] + sql_string_data[1][j]}"]
          # concat << ["#{sql_string_data[0][i][:sql] + sql_string_data[1][j][:sql]}"]
          concat << {sql: sql_string_data[0][i][:sql] + sql_string_data[1][j][:sql],
            #  columns: "#{sql_string_data[0][i][:columns]},#{sql_string_data[1][j][:columns]}",
             columns: sql_string_data[0][i][:columns] + sql_string_data[1][j][:columns],
            #  terms: "#{sql_string_data[0][i][:terms]},#{sql_string_data[1][j][:terms]}"}
             terms: sql_string_data[0][i][:terms] + sql_string_data[1][j][:terms]}
          # concat << ["#{sql_string_data[q][i] + sql_string_data[q+1][j]}"]
        end
      end
    # end

    concat.each do |test|
      # result = Card.find_by_sql(test)
      result = Card.find_by_sql(test[:sql])

      if !result.empty?
        puts "Columns #{test[:columns]}"
        puts "result found #{result}"
        # terms = test[:terms].flatten.uniq
        puts "terms #{test[:terms].uniq}"
        # puts "terms #{terms}"
      end
    end







    # Concatenate sql statements to use all queries in single statement
    # sql_tests = []

    # iterations = sql_string_data.length
    # eval_string = ''

    # sql_concat = []
    # index = 0
    #
    # for q in 0..(queries.count-2) do
    #   for i in 0..(columns.count-1) do
    #     for j in 0..(columns.count-1) do
    #       if !sql_concat[index]
    #         sql_concat[index] = []
    #       end
    #       sql_concat[index] << [(sql_string_data[q][i] << sql_string_data[q+1][j])]
    #       index = index + 1
    #       # sql_concat << sql_string_data[q].zip(sql_string_data[q+1])
    #     end
    #   end
    # end
    #
    # puts "sql_concat #{sql_concat}"

    # zipped = []

    # for(i=0; i<columns.length; i++){
    # for q in 0..(queries.length-2)
    #   for i in 0..(columns.count-1) do
    #     # for(j=0; j<columns.length; j++){
    #     for j in 0..(columns.count-1) do
    #       puts "testing with i #{i} and j #{j}"
    #
    #       zipped = sql_string_data[q].zip(sql_string_data[q+1])
    #       zipped = zipped.map {|z| z.join('') }
    #     end
    #   end
    # end
    # sql_string_data.each_with_index do |sql, index|
      # puts "zip attempt #{sql_string_data[0].zip(sql_string_data[1])}"
      # zipped = sql_string_data[0].zip(sql_string_data[1])
      # zipped = zipped.map {|z| z.join('') }
      # puts "zipped result = #{zipped}"
    # end


    # sql_string_data.each do |col|

    # end


    # sql_tests = []
    # sql_query_string = ''
    # query_sql_chained = []

    # sql_string_data.each do |query_sql|
    #   chain = ''
    #   query_sql.each do |col|
    #
    #   end
    #
    #   if query_sql_chained.empty?
    #
    #   else
    #   end
    # end

    # Test all sql statements, store those that yeild hits as match hashes

    # puts "sql_string_data is #{sql_string_data}"

    return results_arr
  end

  # def self.get_matches queries
  #   cards = Card.all
  #   new_cards = Card.none
  #   results_arr = []
  #   columns = get_relevant_columns()
  #
  #   queries.each do |query|
  #     columns.each do |col|
  #       card_matches = cards.send("_#{col}", query)
  #
  #       unless card_matches.empty?
  #         card_matches.each do |card|
  #           test = results_arr.select { |elem|
  #             elem[:card].id == card[:id]
  #           }
  #
  #           if test.length > 0
  #             elem = test.first
  #             elem[:columns] << col
  #             term = isolate_term(card["#{col}"], query)
  #             elem[:terms] << term
  #           else
  #             term = isolate_term(card["#{col}"], query)
  #             # results_arr << {card: card, columns: [col], terms: [card["#{col}"]]}
  #             results_arr << {card: card, columns: [col], terms: [term] }
  #           end
  #         end
  #         # cards = card_matches
  #         # new_cards << card_matches
  #       end
  #     end
  #     # cards = new_cards
  #   end
  #
  #   # FIXME remove results unless all queries represented among terms
  #   # NOTE Close to the solution here
  #   queries.each do |query|
  #     rgx = query_to_regex(query)
  #
  #     results_arr.delete_if{|elem|
  #       elem[:terms].any?{|term|
  #         if is_numeric? term
  #           term == query
  #         else
  #           rgx.match(term) != nil
  #         end
  #       }
  #     }
  #   end
  #
  #   # NOTE SOMEWHAT WORKS!
  #   results_arr.delete_if{|elem| elem[:columns].length < queries.length}
  #
  #   return results_arr
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
