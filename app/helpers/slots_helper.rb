module SlotsHelper
  def direct_card_assign slot, card
    @slot = slot

    @slot.cards = [card]

    @slot.update_attribute(:queries, "")
    @slot.update_attribute(:image_url, card.image_url)

    @slot.save
  end
end
