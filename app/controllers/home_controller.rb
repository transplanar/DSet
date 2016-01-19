#NOTE chain .where queries to get array of desired cards
class HomeController < ApplicationController
  # TODO move this to more appropriate controller?
  # TODO error message for invalid queries ("no results found")
  # NOTE will not need this if statement once multi-category search is implemented
  def index
    unless params[:search].blank?
      @results = Hash.new
      # @results = [][]

      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at']
      columns = Card.attribute_names - exclude_columns

      # NOTE Currently, this only tests against the last
      @cards = []

      # FIXME shows all results if a query is empty
      columns.each do |col|
        # unless (Card.where("#{col} LIKE ?","%#{params[:search]}%")).count > 1
          # @results[col] = Card.where("#{col} LIKE ?","%#{params[:search]}%")
          # @results = Card.where("#{col} LIKE ?","%#{params[:search]}%")
          # @results.push(col)


          # NOTE this almost works
          # FIXME refactor @cards
          # @cards = Card.where("#{col} LIKE ?","%#{params[:search]}%")
          cards = Card.where("#{col} LIKE ?","%#{params[:search]}%")
          # @results[col]  = cards unless cards.empty?
          @results[col]  = cards unless cards.empty?
        # end
      end

      # Output results for testing
      puts ">>>>>>>Results #{@results}"

      @results.each do |k,v|
        v.each do |card|
          puts "Card = #{card[:name]} in #{k}"
        end
      end


      # puts ">>>>>>First result #{@results.first.name}"
      # puts "THING ----> #{@results[:terminality]}"

      # @results

    else
      puts "Doing this"
      @results = {}
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def about
  end

  private

  def is_numeric?(obj)
     obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end
