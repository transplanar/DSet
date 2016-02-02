#NOTE chain .where queries to get array of desired cards
class HomeController < ApplicationController
  # TODO move this to more appropriate controller?
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
