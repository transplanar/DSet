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
        get :index, {search: "cantrip"}, format: :js

        cards = card_array_from_results

        expect(cards.count).to eq(2)
      end

      it 'returns correct number of search matches for NUMERIC input' do
        get :index, {search: 2}, format: :js

        cards = card_array_from_results

        expect(cards.count).to eq(3)
      end
    end

    describe 'display results across multiple categories ' do
      before :each do
        @results = Card.search('vil')
      end

      it 'finds results in three categories' do
        expect(@results.count).to eq(3)
      end

      it 'finds one \'name\' result' do
        expect(@results['name'].count).to eq(1)
      end

      it 'finds two \'category\' results' do
        expect(@results['category'].count).to eq(2)
      end

      it 'finds two \'terminality\' results' do
        expect(@results['terminality'].count).to eq(1)
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
