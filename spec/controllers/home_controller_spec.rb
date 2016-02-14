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
    describe 'home#generate_cards' do
      it 'should change the image for all slots' do
        original_image_url = Slot.first[:image_url]
        post :generate_cards
        updated_image_url = Slot.first[:image_url]

        expect(original_image_url).not_to eq(updated_image_url)
      end
    end
  end
end
