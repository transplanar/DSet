module SlotsHelper
  def direct_card_assign slot, card
    @slot = slot

    @slot.cards = [card]

    @slot.update_attribute(:queries, '')
    @slot.update_attribute(:image_url, card.image_url)

    @slot.save
  end

  def cards_from_result(hsh)
    hsh.map { |_, v| v.map { |_, v2| v2[:card] } }.flatten
  end

  def names_from_result(hsh)
    cards_from_result(hsh).map(&:name)
  end

  def columns_from_result(hsh)
    hsh.map { |_, v| v.map { |_, v2| v2[:columns] } }.flatten.uniq
  end
end
