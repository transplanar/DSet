class HomeController < ApplicationController
  @@chosen_cards = []

  def index
    @slots = Slot.all

    # NOTE used for randomizing cards
    # generate_cards(@slots)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def about
    @slots = Slot.all

    generate_cards(@slots)
  end

  def generate_cards slots

    slots.each do |slot|
      if slot.cards.blank? && slot.sql_prepend.blank?
        slot.cards = Card.all
      end

      random_card = slot.cards.sample

      while chosen_cards.include? random_card
        random_card = slot.cards.sample
      end

      chosen_cards << random_card

      slot.update_attribute(:image_url, random_card.image_url)
    end
  end
end
