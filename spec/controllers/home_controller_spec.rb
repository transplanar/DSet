require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  # FIXME delete this
  describe 'Home#index' do
    before :each do
      load Rails.root + "db/seeds.rb"
    end

    # it 'renders index template' do
    #   get :index
    #
    #   expect(response).to render_template("index")
    # end

    # FIXME move this to a better spot
      # REVIEW move this to different controller?
    it 'renders index page after search completed' do
      # cards = Card.all
      get :index, {search: "V"}
      cards = assigns(:cards)

      # Rails.logger.info

      cards.each do |card|
        puts card.name
      end

      # assigns(:cards).count.should eq(1)
      expect(cards.count).to eq(3)
    end

  end

  # FIXME delete this
  describe 'Home#about' do
    # it 'renders about template' do
    #   get :about
    #
    #   expect(response).to render_template("about")
    # end
  end

end
