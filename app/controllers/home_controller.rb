#NOTE chain .where queries to get array of desired cards
class HomeController < ApplicationController
  # TODO move this to more appropriate controller?
  # TODO error message for invalid queries ("no results found")
  # NOTE will not need this if statement once multi-category search is implemented
  def index
    # @results = Card.search(params[:search])

    # use_fuzzy_search = params[:use_fuzzy_search]

    # puts "USING FUZZY SEARCH? #{params[:use_fuzzy_search]}"
    # puts "USING FUZZY SEARCH? #{params[:fuzzy]}"
    # puts "USING FUZZY SEARCH? #{use_fuzzy_search}"
    puts "USING FUZZY SEARCH? #{@use_fuzzy_search}"

    @results = Card.search(params[:search], params[:use_fuzzy_search])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def about
  end

  def toggle_fuzzy_search bool
    @use_fuzzy_search = bool
  end
end
