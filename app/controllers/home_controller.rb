class HomeController < ApplicationController
  def index
    # TODO move this to more appropriate controller?
    # TODO error message for invalid queries ("no results found")
    # NOTE will not need this if statement once multi-category search is implemented
    #NOTE chain .where queries to get array of desired cards
    if is_numeric?(params[:search])
      @cards = Card.where('cost LIKE ?',"%#{params[:search]}%")
    else
      @cards = Card.where('name LIKE ?',"%#{params[:search]}%")
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
