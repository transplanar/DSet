require 'rails_helper'
require 'awesome_print'

RSpec.describe SlotsController, type: :controller do
  let(:my_slot) { Slot.create! }

  before :each do
    load Rails.root + 'db/seeds.rb'
    my_slot.cards = Card.all
  end

  describe 'GET show' do
    it 'renders slot view' do
      get :show, id: my_slot.id
      expect(response).to have_http_status(:success)
    end
  end

  describe 'card search' do
    describe 'with a single query' do
      it 'returns correct number of matches for ALPHABETICAL input' do
        get :show, { id: my_slot.id, search: 'cantrip' }, format: :js

        results = assigns(:results)

        expect(results.first.count).to eq(2)
      end

      # FIXME why is this broken? Displaying 2x expected results
      it 'returns correct number of search matches for NUMERIC input' do
        get :show, {id: my_slot.id, search: 2}, format: :js

        # cards = card_array_from_results
        results = assigns(:results)
        # p "RESULTS RAW #{results}"
        # p "raw length #{results.length}"

        # cards = results.map(|k,_| k[:cards])
        # p "Cards #{cards}"

        # p "Cost column #{results["Cost"].length}"
        # p "Cards #{results["Cost"].map{ |elem| elem[:card][:name] }}"
        expect(results["Cost"].map{ |elem| elem[:card] }.length).to eq(3)
        # expect(cards.length).to eq(3)

      end
    end

    describe 'with a multi-query' do
      it 'returns correct number of matches for 2-part query' do
        get :show, { id: my_slot.id, search: 'v 3' }, format: :js

        results = assigns(:results)
        # ap "Multi query result  #{results}"
        # ap "Multi query result  #{results.size}"

        expect(results.first.count).to eq(3)
      end
    end
  end

  describe 'direct card assignment' do
    it 'should assign a singular card' do
      expect(my_slot.cards.count).to eq(25)

      post :assign_card, {slot_id: my_slot.id, id: Card.first.id}

      expect(my_slot.cards.first).to eq(Card.first)
    end
  end


  describe 'assigning filters' do
    it 'should assign the desired filter' do
      expect(my_slot.cards.count).to eq(25)

      post :assign_filter, {slot_id: my_slot.id, col: 'name', term: 'village'}

      expect(my_slot.cards.count).to eq(1)
    end
  end

  describe 'deleting filters' do
    it 'should delete selected filter' do
      post :assign_filter, {slot_id: my_slot.id, col: 'category', term: 'village'}
      expect(my_slot.cards.count).to eq(2)

      pair = 'category: Village'

      patch :delete_filter, {slot_id: my_slot.id, pair: pair}
      expect(my_slot.cards.count).to eq(0)
    end
  end

  # private
  #
  # def card_array_from_results
  #   results = assigns(:results)
  #   cards = []
  #
  #   results.each do |k,v|
  #     v.each do |card|
  #       cards << card
  #     end
  #   end
  #
  #   return cards
  # end
end
