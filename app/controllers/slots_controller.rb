class SlotsController < ApplicationController
  def show
    @slot = Slot.find(params[:id])

    @results, @matched_terms = Card.search(params[:search], @slot)
  end

  def assign_card
    @slot = Slot.find(params[:slot_id])

    card = Card.find(params[:id])

    @slot.cards = [card]

    @slot.update_attribute(:queries, "")
    # XXX FIGURE OUT WHY THIS ISN'T WORKING
    @slot.update_attribute(:image_url, card.image_url)

    puts "Cards allowed in slot #{@slot.id} = #{@slot.cards.inspect}"

    redirect_to slot_path(@slot)
  end
end
