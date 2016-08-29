require 'rails_helper'

RSpec.describe Slot, type: :model do
  before :each do
    load Rails.root + "db/seeds.rb"
  end

  describe 'search scopes' do
    before :each do
      @test_card = Card.first
    end

    context 'name search' do
      it "cellar should appear in a name search" do
        @results, @matching_terms = Card.search('cel', Slot.first)

        expect(@results['name']).to include(@test_card)
      end

      it "cellar should NOT appear in a cost search" do
        @results, @matching_terms = Card.search('cel', Slot.first)

        if @results['cost'].nil?
          @results['cost'] = {}
        end

        expect(@results['cost']).not_to include(@test_card)
      end

      it 'cellar should NOT appear in an irrelevant search' do
        @results, @matching_terms = Card.search('x', Slot.first)

        result_values = values_from_results

        expect(result_values).not_to include(@test_card)
      end
    end
  end

  describe 'Searches across multiple categories' do
    before :each do
      @results, @matching_terms = Card.search('vil', Slot.first)
    end

    it 'finds results in three categories' do
      expect(@results.count).to eq(2)
    end

    it 'finds one \'name\' result' do
      expect(@results['name'].count).to eq(1)
    end

    it 'finds two \'category\' results' do
      expect(@results['category'].count).to eq(2)
    end
  end

  describe 'Multi-query search' do
    before :each do
      @results, @matching_terms = Card.search('v 3', Slot.first)
    end

    it 'finds three unique matching cards' do
      expect(@results.count).to eq(3)
    end

    it 'finds two matches in terminality > cost' do
      expect(@results["terminality > cost"].count).to eq(2)
    end

    it 'saves 3 acceptable cards to this slot' do
      expect(Slot.first.cards.count).to eq(3)
    end

    it 'saves all acceptable cards to this slot' do
      result_values = values_from_results

      expect(Slot.first.cards).to include(result_values.first)
      expect(Slot.first.cards).to include(result_values.second)
      expect(Slot.first.cards).to include(result_values.third)
    end
  end

  describe 'non-consecutive matching' do
    before :each do
      @results, @matching_terms = Card.search('vlg', Slot.first)
    end

    it 'should display \'village\' as first result' do
      result_values = values_from_results
      expect(result_values.first.name.downcase).to eq('village')
    end
  end

  def values_from_results
    values = []

    @results.each do |k, v|
      values << v.first
    end

    return values
  end
end
