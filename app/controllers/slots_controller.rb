class SlotsController < ApplicationController
  # def index
  #   @slot = Slot.find(params[:id])
  #
  # end

  def show
    @slot = Slot.find(params[:id])

    @results, @matched_terms = Card.search(params[:search], @slot)
  end
end
