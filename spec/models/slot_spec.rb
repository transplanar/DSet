include SlotsHelper
require 'rails_helper'

RSpec.describe Slot, type: :model do
  before :each do
    load Rails.root + "db/seeds.rb"
    @test_card = Card.first
  end

  describe 'search scopes' do
    before :each do
      @results = Card.search('cel', Slot.first)
      @cards = cards_from_result(@results)
    end

    context 'name search' do
      it "cellar should appear in a name search" do
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
        @cards = cards_from_result_hash(@results)

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
      expect(@columns).to eq(%w(Name Terminality Archetype).sort)
    end

    it 'finds one \'name\' result' do
      expect(@columns).to include('Name')
    end

    # it 'finds two \'category\' results' do
    #   expect(@columns).to include('category')
    # end
  end

  describe 'Multi-query search' do
    before :each do
      @results = Card.search('v 3', Slot.first)
    end

    it 'finds three unique matching cards' do
      expect(@cards.count).to eq(3)
    end

    # it 'finds two matches in terminality > cost' do
    #   # expect(@results["terminality"].count).to eq(2)
    # end

    # it 'saves 3 acceptable cards to this slot' do
    #   expect(Slot.first.cards.count).to eq(3)
    # end

    # it 'saves all acceptable cards to this slot' do
    #   result_values = values_from_results

    #   expect(Slot.first.cards).to include(result_values.first)
    #   expect(Slot.first.cards).to include(result_values.second)
    #   expect(Slot.first.cards).to include(result_values.third)
    # end
  end

  describe 'non-consecutive matching' do
    before :each do
      @results = Card.search('vlg', Slot.first)
    end

    it 'should display \'village\' as first result' do
      result_values = values_from_results
      expect(result_values.first.name.downcase).to eq('village')
    end
  end
  
  # def cards_from_result_hash hsh
  #   return hsh.map{|k,v| v.map{|k2,v2| v2[:card]}}.flatten
  #   # return hsh.keys.flatten.uniq
  # end
  
  # def cards_from_result_hash hsh
  #   return hsh.map{|k,v| v.map{|k2,v2| v2[:columns]}}.flatten
  # end

  # def values_from_results
  #   values = []

  #   @results.each do |k, v|
  #     values << v.first
  #   end

  #   return values
  # end
end
