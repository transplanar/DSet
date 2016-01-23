class Card < ActiveRecord::Base
  fuzzily_searchable :name, :types, :category, :expansion, :strategy, :terminality


  def self.search search, use_fuzzy_search
    unless search.blank?
      @results = Hash.new

      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at']
      columns = Card.attribute_names - exclude_columns

      search_queries = search.split(', ')
      # puts "QUERIES = #{search_queries}"

      @cards = []
      @matched_terms = []


      search_queries.each do |query|
        columns.each do |col|
          if use_fuzzy_search && !is_numeric?(query)
            cards = Card.send("find_by_fuzzy_#{col}", query)
          else
            if @results.blank?
              cards = Card.where("#{col} LIKE ?","%#{query}%")
            else
              cards = Card.where("#{col} LIKE ?","%#{query}%")

              # puts @results.where("#{col} LIKE ?","%#{query}%")
              # puts Card.where(@results[col].map(&:card_id).uniq)

              # @results.where("#{col} LIKE ?","%#{query}%")

              # puts "TEST #{ @results.select{ |c| c["#{col}"] == query}  } "


              # cards = Card.where("#{col} LIKE ?","%#{query}%")

              # cards = @results.select(|card|           )
              # cards = Card.where(@results[col].map(&:col).uniq)
            end
          end

          unless cards.empty?
            @results[col]  = cards

            unless col == "name"
              cards.each do |c|

                split_terms = c["#{col}"].split(',')

                split_terms.each do |term|
                  # puts "#{term} vs #{query} is #{term.include? query}"
                  if term.downcase.include? query.downcase
                    @matched_terms << "<b>#{col}</b>: #{term}"
                    @matched_terms.uniq!
                  end
                end
              end
            end
            # puts "Matched terms array #{@matched_terms}"
          end
        end
      end

      # WORKING
      # columns.each do |col|
      #   if use_fuzzy_search && !is_numeric?(search)
      #     cards = Card.send("find_by_fuzzy_#{col}", search)
      #   else
      #     cards = Card.where("#{col} LIKE ?","%#{search}%")
      #   end
      #
      #   unless cards.empty?
      #     @results[col]  = cards
      #
      #     unless col == "name"
      #       cards.each do |c|
      #
      #         split_terms = c["#{col}"].split(',')
      #
      #         split_terms.each do |term|
      #           puts "#{term} vs #{search} is #{term.include? search}"
      #           if term.downcase.include? search.downcase
      #             @matched_terms << "<b>#{col}</b>: #{term}"
      #             # @matched_terms << term
      #             @matched_terms.uniq!
      #           end
      #         end
      #       end
      #     end
      #     puts "Matched terms array #{@matched_terms}"
      #   end
      # end

      # XXX FOR TESTING
      # puts ">>>>>>>Results #{@results}"
      #
      @results.each do |k,v|
        v.each do |card|
          p "Card = #{card[:name]} in #{k}"
        end
      end

      # puts "FLATTEN 1x #{@results.flatten(1)}"
      # puts "FLATTEN 2x #{@results.flatten}"
      # puts "TEST #{ @results.select{ |c| c["name"] == query}  } "
      #>>>>>>>>>>>>>>>>>>>>>>>>>

    else
      @results = {}
      @matched_terms = {}
    end



    return [@results, @matched_terms]
  end

   def self.is_numeric?(obj)
      obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
   end
end
