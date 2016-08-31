require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  before :each do
    load Rails.root + "db/seeds.rb"
  end

  context 'routing' do
    describe 'Home#index' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'Home#generate_cards' do
      it 'returns http success' do
        get :generate_cards
        expect(response).to have_http_status(:success)
      end
    end

    describe 'Home#clear_filters' do
      it 'returns http success' do
        get :clear_filters
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'button functions' do
    describe 'generate card set button' do
      it 'should update the image for all slots' do
        original_image_url = Slot.first[:image_url]
        post :generate_cards
        updated_image_url = Slot.first[:image_url]

        expect(original_image_url).not_to eq(updated_image_url)
      end
    end

    describe 'clear filters button' do
      before :each do
        @slots = Slot.all
      end

      it 'should clear directly assigned cards' do
        @test_card = Card.first

        @slots.each do |slot|
          slot.cards = [@test_card]
          expect(slot.cards.count).to eq(1)
        end

        post :clear_filters

        @slots.each do |slot|
          expect(slot.cards.count).to eq(25)
        end
      end

      it 'should clear saved search queries' do
        @slots.each do |slot|
          Card.search('v 3', slot)
          expect(slot[:queries]).to eq('v 3')
        end

        post :clear_filters

        @slots = Slot.all

        @slots.each do |slot|
          expect(slot[:queries]).to be_empty
        end
      end
    end
  end
end
