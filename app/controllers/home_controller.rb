#NOTE chain .where queries to get array of desired cards
class HomeController < ApplicationController
  # TODO move this to more appropriate controller?
  # TODO error message for invalid queries ("no results found")
  # NOTE will not need this if statement once multi-category search is implemented
  def index
    @results, @matched_terms, @multisearch = Card.search(params[:search])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def about
  end
end
