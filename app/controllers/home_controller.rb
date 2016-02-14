class HomeController < ApplicationController
  @@chosen_cards = []

  def index
    @slots = Slot.all

    respond_to do |format|
      format.html
      format.js
    end
  end

  def about
    @slots = Slot.all

    generate_cards(@slots)
  end

  def generate_cards
    @slots = Slot.all
    chosen_cards = []

    @slots.each do |slot|
      if slot.cards.blank?
        slot.cards = Card.all
      end

      random_card = slot.cards.sample

      while chosen_cards.include? random_card
        random_card = slot.cards.sample
      end

      chosen_cards << random_card

      slot.update_attribute(:image_url, random_card.image_url)
    end

    render 'home/index'
  end

  def clear_filters
    @slots = Slot.all

    @slots.each do |slot|
      slot[:filters_humanized] = ""
      slot[:sql_prepend] = ""
      slot[:queries] = ""
      slot.update_attribute(:image_url, "http://vignette2.wikia.nocookie.net/dominioncg/images/6/65/Randomizer.jpg/revision/latest?cb=20100224111917")
    end

    render 'home/index'

  end
end
