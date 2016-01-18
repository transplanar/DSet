require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  # FIXME delete this
  describe 'Home#index' do
    before :each do
      load Rails.root + "db/seeds.rb"
    end

    # FIXME move this to a better spot
      # REVIEW move this to different controller?
    it 'returns correct number of search matches for ALPHABETICAL input' do
      # get :index, {search: "V"}
      get :index, {search: "V"}, format: :js
      cards = assigns(:cards)

      expect(cards.count).to eq(3)
    end

    it 'returns correct number of search matches for NUMERIC input' do
      # get :index, {search: 2}
      get :index, {search: 2}, format: :js
      cards = assigns(:cards)

      expect(cards.count).to eq(3)
    end

    context 'multi-field queries' do
      # get :index, {search: "Vi"}, format: :js
      # cards = assigns(:cards)
      #
      # expect(cards.count).to eq(3)

      # search multiple 

    end
  end

  # FIXME delete this
  # describe 'Home#about' do
    # it 'renders about template' do
    #   get :about
    #
    #   expect(response).to render_template("about")
    # end
  # end

end
