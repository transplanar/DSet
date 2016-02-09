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

  # def generate_cards slots
  def generate_cards
    puts "Executing card set generator"

    slots = Slot.all
    chosen_cards = []

    slots.each do |slot|
      puts "Generating card for slot #{slot.id}"


      if slot.cards.blank?
        slot.cards = Card.all
      end

      random_card = slot.cards.sample

      puts "Current chosen cards: #{chosen_cards}"

      while chosen_cards.include? random_card
        random_card = slot.cards.sample
      end

      chosen_cards << random_card

      slot.update_attribute(:image_url, random_card.image_url)
    end

    redirect_to root_path

    respond_to do |format|
      format.html
      format.js
    end
  end
end
