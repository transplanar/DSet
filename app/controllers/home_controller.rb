#NOTE chain .where queries to get array of desired cards
class HomeController < ApplicationController
  # TODO move this to more appropriate controller?
  # TODO error message for invalid queries ("no results found")
  # NOTE will not need this if statement once multi-category search is implemented
  def index
    unless params[:search].nil?
      @results = Hash.new
      # @results = [][]

      exclude_columns = ['id', 'image_url', 'created_at', 'updated_at']
      columns = Card.attribute_names - exclude_columns

      # NOTE Currently, this only tests against the last
      @cards = []

      columns.each do |col|
        # unless (Card.where("#{col} LIKE ?","%#{params[:search]}%")).count > 1
          # @results[col] = Card.where("#{col} LIKE ?","%#{params[:search]}%")
          # @results = Card.where("#{col} LIKE ?","%#{params[:search]}%")
          # @results.push(col)


          # NOTE this almost works
          @cards = Card.where("#{col} LIKE ?","%#{params[:search]}%")
        # end
      end

      # Output results for testing
      # puts ">>>>>>>Results #{@results}"
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
      # @results={}
      # @results = []

      # search_attributes = Card.columns.except(:id, :image_url, :created_at, :updated_at)
      # search_attributes = Card.columns.select_without(:id, :image_url, :created_at, :updated_at)

      # columns = ['name']


      #
      # # search_attributes = Card.select(columns)
      #
      # puts "attributes"
      # # puts search_attributes
      # # puts search_attributes["name"]
      #
      # Card.all.each do |card|
        # card.attributes.each_pair do |key, val|
        # card.attributes.each_pair do |key, val|
        # search_attributes.each_pair do |key, val|
          # @cards = Card.where()
          # XXX does this work?
          # @cards = Card.where('#{key} LIKE ?',"%#{params[:search]}%")
          # puts "#{key} and #{val}"
          # puts Card.where("#{key} LIKE ?","%#{params[:search]}%").last
          # results[key] = Card.where("#{key} LIKE ?","%#{params[:search]}%")
          # unless (key: 'id')

          # REVIEW why is this storing every card regardless of input
          # @results[col] = Card.where("#{col} LIKE ?","%#{params[:search]}%")

          # puts "Count is #{Card.where("#{col} LIKE ?", params[:search]).count}"

          # if (Card.where("#{col} LIKE ?", params[:search]).count > 0)
            # @results[col] = Card.where("#{col} LIKE ?", params[:search])
          # end

      # end



      # FIXME basically reseeding with data that already exists in Card.all?
      #
      # Card.all.each do |card|
      #   card.attributes.each_pair do |key, val|
      #   # search_attributes.each_pair do |key, val|
      #     # @cards = Card.where()
      #     # XXX does this work?
      #     # @cards = Card.where('#{key} LIKE ?',"%#{params[:search]}%")
      #     # puts "#{key} and #{val}"
      #     # puts Card.where("#{key} LIKE ?","%#{params[:search]}%").last
      #     # results[key] = Card.where("#{key} LIKE ?","%#{params[:search]}%")
      #     # unless (key: 'id')
      #     @results[key] = Card.where("#{key} LIKE ?","%#{params[:search]}%")
      #     # end
      #   end
      # end
      #
      #
      # puts @results

      # @cards = results.flatten

      # results.each do |result|
      #
      # end
      #


      # if is_numeric?(params[:search])
      #   @cards = Card.where('cost LIKE ?',"%#{params[:search]}%")
      # else
      #   @cards = Card.where('name LIKE ?',"%#{params[:search]}%")
      # end

  def about
  end

  private

  def is_numeric?(obj)
     obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end
