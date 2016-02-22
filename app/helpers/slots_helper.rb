module SlotsHelper
  def assign_card slot, card
    @slot = slot

    @slot.cards = [card]

    @slot.update_attribute(:queries, "")
    @slot.update_attribute(:image_url, card.image_url)

    @slot.save
  end
end
