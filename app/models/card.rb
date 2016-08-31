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
      columns = get_relevant_columns()

      unless is_numeric?(search_str)
        search_queries = search_str.split
      else
        search_queries = [search_str.to_s]
      end

      # results = regex_test(search_queries, columns, slot)
      sql_hash = regex_test(search_queries, columns, slot)


      # sql_hash = generate_sql_hash(search_queries, columns, slot)
      #
      results = generate_results_from_sql (sql_hash)
      #
      # matched_terms = get_matching_terms(search_queries, columns, results)
      #
      # save_cards_to_slot(search_str, results, slot)
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

  # # Experimental version
  # def self.regex_test user_input, columns, slot
  #   results_hash = Hash.new
  #
  #   if user_input.length == 1
  #     letter_regex = get_regex_from_partial_string(user_input.first)
  #
  #     columns.each do |col|
  #       test_search = Card.send("_#{col}", letter_regex)
  #
  #       unless test_search.blank?
  #         results_hash[col] = test_search.to_sql
  #       end
  #     end
  #   else
  #     term_arr = []
  #     index = 0
  #     # eval_string =  ""
  #     eval_arr =  []
  #     eval_hash = Hash.new
  #     matched_columns = []
  #
  #     user_input.each do |query|
  #       term_arr << get_regex_from_partial_string(query)
  #     end
  #
  #     puts "term array = #{term_arr}"
  #
  #     columns.each do |col|
  #       cards = Card.send("_#{col}", term_arr[index])
  #       # puts "cards from send #{cards}"
  #
  #       unless cards.empty?
  #         # eval_string << ".send(\"_#{col}\", \"#{term_arr[index]}\")"
  #         eval_arr << ".send(\"_#{col}\", \"#{term_arr[index]}\")"
  #         # eval_hash[col] = ".send(\"_#{col}\", \"#{term_arr[index]}\")"
  #         matched_columns << col
  #       end
  #     end
  #
  #     # unmatched_columns = columns - matched_columns
  #
  #
  #     # puts "eval string #{eval_string}"
  #     # puts "eval string #{eval_hash}"
  #     # chain_scopes(eval_string[0])
  #     # chain_scopes(columns, eval_string[0], index, term_arr.length)
  #
  #     # unmatched_columns = columns - matched_columns[0]
  #     unmatched_columns = Array.new(columns)
  #     unmatched_columns.delete(matched_columns[0])
  #
  #     # chain_scopes(columns, term_arr, eval_arr[0], index, term_arr.length)
  #     index = index + 1
  #     results = chain_scopes(unmatched_columns, term_arr, eval_arr[0], index, term_arr.length)
  #   end
  #
  #   # results =
  #
  #   return results_hash
  # end

  # ###########################################################################################
  # ###########################################################################################
    # Confirmed version
  def self.regex_test user_input, columns, slot
    multi_result = Hash.new
    results_hash = Hash.new
    matched_columns = []

    user_input.each do |query|
      letter_str = ""
      column_string = ''
      num_matched_terms = 0
      letters = query.first.chars

      letters.each do |letter|
        if letter === letters.first
          letter_str << "[#{letter}]"
        else
          letter_str <<  ".*?[#{letter}]"
        end
      end

      if query === user_input.first
        columns.each do |col|
          test_search = Card.send("_#{col}", letter_str)

          unless test_search.blank?
            results_hash[col] = test_search.to_sql
            matched_columns << col unless matched_columns.include? col
          end
        end
      else
        columns.each do |col|
          if multi_result.count > 0
            hash = multi_result.clone
          else
            hash = results_hash
          end

          hash.each do |result_key, sql|
            unless result_key.include? col
              test_search = Card.send("_#{col}", letter_str)
              unless test_search.blank?

                sql_to_chain = test_search.to_sql.gsub("SELECT \"cards\".* FROM \"cards\" WHERE ", "")

                multi_result["#{result_key} > #{col}"] = sql + " AND " + sql_to_chain
              end
            end
          end
        end
      end
    end

    unless user_input.count > 1
      results = results_hash
    else
      results = multi_result

      # split_keys = []
      #
      # multi_result.keys.each do |key|
      #   split_keys << key.split(" > ")
      # end
    end

    return results
  end
  # ###########################################################################################
  # ###########################################################################################

  private



  # def self.chain_scopes eval_string, columns, index=0
  def self.chain_scopes columns, term_arr, eval_string=nil, index=0, max_index
    result_string = ''

    if index < max_index
      columns.each do |col|
        test_str = ''
        unless eval_string.nil?
          test_str << eval_string
          old_card_set = eval( "Card#{eval_string}" )
        end

        test_str << ".send(\"_#{col}\", \"#{term_arr[index]}\")"
        new_card_set = eval( "Card#{test_str}" )

        continue = false

        unless eval_string.nil?
          if old_card_set.count != new_card_set.count
            continue = true
          end

        else
          unless new_card_set.blank?
            continue = true
          end
        end

        if continue
          index = index + 1
          columns.delete(col)
          result_string = test_str

          chain_scopes(columns, term_arr, test_str, index, max_index)
        end
      end
    end

    puts "result string #{result_string}"

    return result_string
  end

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

  # def self.chain_scopes cards, scopes, queries
  #
  #   def test_scope cards, scope_str
  #
  #   end
  # end

  # def self.test_scope cards, scopes, query
  #   scopes.each do |s|
  #     test = cards.send("_#{s}", query)
  #
  #     if test.any?
  #       test_scope(test, scopes, )
  #     end
  #   end
  # end

  # def self.chain_scopes (cards, scope, queries)
  #
  #
  #   test = cards.send("_#{scope}", query)
  #   if test.any?
  #     chain_scopes(test, scope.next, query)
  #   else
  #     # ????
  #   end
  #
  #   # test = cards.send("#{scope}", term)
  # end

  def self.get_relevant_columns
    exclude_columns = ['id', 'image_url', 'created_at', 'updated_at', 'slot_id']
    Card.attribute_names - exclude_columns
  end

  def self.is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def self.generate_sql_hash queries, columns, slot
    # query = queries.first

    results_hash = Hash.new
    multi_result = Hash.new
    header_string = ""


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

              header_string =  col
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
