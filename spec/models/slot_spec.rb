require 'rails_helper'

RSpec.describe Slot, type: :model do
  include SlotsHelper

  before :each do
    load Rails.root + "db/seeds.rb"
    @test_card = Card.first
  end

  describe 'search scopes' do
    before :each do
      @results = Card.search('cel', Slot.first)
      p "Results are #{@results}"
      @cards = cards_from_result(@results)
    end

    context 'name search' do
      it "'Cellar' should appear in a name search" do
        expect(@cards).to include(@test_card)
      end

      it "cellar should NOT appear in a cost search" do
        # @results = Card.search('cel', Slot.first)

        if @results['cost'].nil?
          @results['cost'] = {}
        end

        expect(@results['cost']).not_to include(@test_card)
        expect(@results['cost']).to be_empty
      end

      it 'cellar should NOT appear in an irrelevant search' do
        @results = Card.search('x', Slot.first)
        @cards = cards_from_result(@results)

        expect(@cards).not_to include(@test_card)
      end
    end
  end

  describe 'Searches across multiple categories' do
    before :each do
      @results = Card.search('v v v', Slot.first)
      @cards = cards_from_result(@results)
      @columns = @results.keys.flatten.uniq.sort
    end

    it 'finds results in three categories' do
      expect(@columns).to eq(%w(Name Terminality Archetype Strategy).sort)
    end

    it 'finds one \'name\' result' do
      expect(@columns).to include('Name')
    end
  end

  describe 'Multi-query search' do
    before :each do
      @results = Card.search('v 3', Slot.first)
      @cards = cards_from_result(@results)
    end

    it 'finds three unique matching cards' do
      expect(@cards.count).to eq(3)
    end
  end

  describe 'non-consecutive matching' do
    before :each do
      @results = Card.search('vlg', Slot.first)
    end

    it 'should display \'village\' as first result' do
      pending("Incomplete")
      result_values = values_from_results
      expect(result_values.first.name.downcase).to eq('village')
    end
  end
end
