require 'rails_helper'

RSpec.describe Card, type: :model do
  let(:card) {Card.create!(name: "TestCard",
                            image_url: "http://example.com/card.jpg",
                            cost: 3,
                            category: "Tester",
                            expansion: "Non-Game",
                            strategy: "Unplayable",
                            terminal: "Terminal"
                            )}


# REVIEW good compromise between atrribute test and excessive tests?
  describe 'attributes' do
    it 'should respond to string params (name)' do
      expect(card).to respond_to(:name)
    end

    it 'should respond to integer params (cost)' do
      expect(card).to respond_to(:cost)
    end
  end

end
