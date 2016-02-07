class SlotsController < ApplicationController
  def show
    @slot = Slot.find(params[:id])

    @results, @matched_terms = Card.search(params[:search], @slot)
  end

  def assign_card
    # TODO prevent users from using this to assign the same card to multiple slots
    @slot = Slot.find(params[:slot_id])

    card = Card.find(params[:id])

    @slot.cards = [card]

    @slot.update_attribute(:queries, "")
    @slot.update_attribute(:image_url, card.image_url)

    redirect_to slot_path(@slot)
  end
end
