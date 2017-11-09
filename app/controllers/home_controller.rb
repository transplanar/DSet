class HomeController < ApplicationController
  def index
    @slots = Slot.order('id ASC').all
    @slots_arr = []

    @slots.each do |slot|
      direct_card_assign(slot, slot.cards.first) if slot.cards.count == 1

      @slots_arr << { slot: slot, path: slot_path(slot) }
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def about; end

  def generate_cards
    @slots = Slot.order('id ASC').all
    preselected_cards = []
    randomize_slots = []

    @slots.each do |slot|
      if slot.cards.count == 1
        preselected_cards << slot.cards.first
      else
        randomize_slots << slot
      end
    end

    randomize_slots.each do |slot|
      slot.cards = Card.all if slot.cards.blank?

      random_card = slot.cards.sample

      while preselected_cards.include? random_card
        random_card = slot.cards.sample
      end

      preselected_cards << random_card

      slot.update_attribute(:image_url, random_card.image_url)
    end

    render 'home/index'
  end

  def clear_filters
    @slots = Slot.order('id ASC').all

    @slots.each do |slot|
      slot[:filters_humanized] = ''
      slot[:sql_prepend] = ''
      slot[:queries] = ''
      slot.cards = Card.all
      slot.update_attribute(:image_url, 'http://vignette2.wikia.nocookie.net/dominioncg/images/6/65/Randomizer.jpg/revision/latest?cb=20100224111917')
      slot.save
    end

    render 'home/index'
  end
end
