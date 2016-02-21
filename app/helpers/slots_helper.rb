module SlotsHelper
  def assign_card slot, card
    # @slot = Slot.find(params[:slot_id])
    @slot = slot

    # card = Card.find(params[card.id])

    @slot.cards = [card]

    @slot.update_attribute(:queries, "")
    @slot.update_attribute(:image_url, card.image_url)

    @slot.save

    # TODO Send back to root?
    # redirect_to slot_path(@slot)
    # redirect_to root_path
    # redirect_to :back
    # redirect_to home_index_path
  end
end
