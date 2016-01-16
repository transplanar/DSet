require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  # FIXME delete this
  describe 'Home#index' do
    it 'renders index template' do
      get :index

      expect(response).to render_template("index")
    end
  end

  # FIXME delete this
  describe 'Home#about' do
    it 'renders about template' do
      get :about

      expect(response).to render_template("about")
    end
  end

end
