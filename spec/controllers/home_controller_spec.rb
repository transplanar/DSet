require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  context 'Home#index' do
    before :each do
      load Rails.root + "db/seeds.rb"
    end


    describe 'card search' do
      # FIXME move this to a better spot
        # REVIEW move this to different controller?
      it 'returns correct number of search matches for ALPHABETICAL input' do
        get :index, {search: "cantrip", use_fuzzy_search: false}, format: :js

        cards = card_array_from_results

        expect(cards.count).to eq(2)
      end

      it 'returns correct number of search matches for NUMERIC input' do
        get :index, {search: 2, use_fuzzy_search: false}, format: :js

        cards = card_array_from_results

        expect(cards.count).to eq(3)
      end
    end

    describe 'display results across multiple categories ' do
      before :each do
        # @results = Card.search('vil', false)
        @results = Card.search('vil', false)
        # get :index, {search: "cantrip", use_fuzzy_search: false}, format: :js
      end

      it 'finds results in three categories' do
        expect(@results.count).to eq(3)
      end

      it 'finds one \'name\' result' do
        expect(@results[0]['name'].count).to eq(1)
      end

      it 'finds two \'category\' results' do
        expect(@results[0]['category'].count).to eq(2)
      end

      # it 'finds two \'terminality\' results' do
        # expect(@results[0]['terminality'].count).to eq(1)
      # end
    end

    describe 'chained query parsing' do
      it 'returns one result' do
        @results = Card.search('village, 5', false)
        expect(@results[0].count).to eq(1)
      end

      it 'returns the FESTIVAL card' do
        @results = Card.search('village, 5', false)
        expect(@results[0][0]['name']).to eq("Festival")
      end

      describe 'locate the Mine card' do
        it 'finds it in type-cost order' do
          @results = Card.search('trash, 5', false)
          expect(@results[0][0]['name']).to eq("Mine")
        end

        it 'finds it in cost-type order' do
          @results = Card.search('5, trash', false)
          expect(@results[0][0]['name']).to eq("Mine")
        end
      end
    end
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
