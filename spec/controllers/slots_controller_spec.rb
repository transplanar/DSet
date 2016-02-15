require 'rails_helper'

RSpec.describe SlotsController, type: :controller do
  let(:my_slot){Slot.create!}

  before :each do
    load Rails.root + "db/seeds.rb"
    my_slot.cards = Card.all
  end


  describe "GET show" do
    it "returns http success" do
      get :show, {id: my_slot.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe 'card search' do
    it 'returns correct number of search matches for ALPHABETICAL input' do
      get :show, {id: my_slot.id, search: "cantrip"}, format: :js

      cards = card_array_from_results()

      expect(cards.count).to eq(2)
    end

    it 'returns correct number of search matches for NUMERIC input' do
      get :show, {id: my_slot.id, search: 2}, format: :js

      cards = card_array_from_results

      expect(cards.count).to eq(3)
    end
  end

  describe 'direct card assignment' do
    it 'should assign a singular card' do
      expect(my_slot.cards.count).to eq(25)

      post :assign_card, {slot_id: my_slot.id, id: Card.first.id}

      expect(my_slot.cards.count).to eq(1)
    end
  end

  private

  def card_array_from_results
    results = assigns(:results)
    cards = []

    results.each do |k,v|
      v.each do |card|
        cards << card
      end
    end

    return cards
  end
end
