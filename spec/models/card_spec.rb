require 'rails_helper'

# TODO rename/move to better spot
RSpec.describe Card, type: :model do
  include SlotsHelper

  before :each do
    load Rails.root + "db/seeds.rb"
  end

  describe 'search scopes' do
    before :each do
      @results = Card.search('cel', Slot.first)
      @cards = cards_from_result(@results)
      @test_card = Card.first
    end

    context 'name search' do
      it "'Cellar' should appear in a name search" do
        expect(@cards).to include(@test_card)
      end

      it "cellar should NOT appear in a cost search" do
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
  
  describe 'chained queries' do
    describe 'numeric/numeric queries' do
      it 'should produce no results' do
        @results = Card.search('3 4', Slot.first)
        
        expect(@results).to be_empty
      end
    end
    
    describe 'numeric/string queries' do
      before :each do
        @results = Card.search('v 3', Slot.first)
        @cards = cards_from_result(@results)
      end
  
      it 'finds three unique matching cards' do
        expect(@cards.count).to eq(3)
      end
      
      it 'key element length should match number of supplied queries' do
        @key_lengths = []
        
        @results.keys.each do |key|
          @key_lengths << key.to_a.length
        end
        
        expect(@key_lengths).to all(be 2) 
      end
    end
    
    describe 'string/string queries' do
      it 'produces consistent results' do
        @all_results = []
        10.times do
          @all_results << Card.search('v v', Slot.first)
        end
        
        expect(@all_results).to all(eq @all_results.first)
      end
      
      describe 'duplicate queries' do
        before :each do
          @results = Card.search('v v', Slot.first)
          @cards = cards_from_result(@results)
          @columns = @results.keys.flatten.uniq.sort
        end
    
      # FIXME sometimes fails for some mysterious reason
        it 'finds results in four categories' do
          pending("Inconsistent result. Refactor?")
          # @expected_columns = []
          # @expected_columns = (%w(Name Terminality Archetype Strategy)).sort
          # @expected_columns = (%w(Name Terminality Archetype Card\ Type)).sort
          # @expected_columns = ['Name', 'Terminality', 'Archetype', 'Card Type'].sort
          @expected_columns = ['Name', 'Terminality', 'Archetype', 'Strategy'].sort
          
          expect(@columns.length).to eq(4)
          expect(@columns).to eq(@expected_columns)
        end
    
        it 'only displays results with a hit against all supplied queries' do
          pending("Refactor required")
          @lengths = []
          @results.keys.each do |set|
            @lengths << set.to_a.length
          end
          
          expect(@lengths).to all(be 2)
        end
      end
      
      describe 'differentiated queries' do
        pending("Incomplete")
      #   before :each do
      #     @results = Card.search('v c', Slot.first)
      #     @cards = cards_from_result(@results)
      #     @columns = @results.keys.flatten.uniq.sort
      #   end
    
      #   it 'finds results in four categories' do
      #     @expected = (%w(Name Terminality Archetype Card\ Type)).sort
          
      #     expect(@columns.length).to eq(4)
      #     expect(@columns).to eq(@expected)
      #   end
    
      #   it 'only displays results with a hit against all supplied queries' do
      #     @lengths = []
      #     @results.keys.each do |set|
      #       @lengths << set.to_a.length
      #     end
          
      #     expect(@lengths).to all(be 2)
      #   end
      end
    end
    
    describe '2+ query chains' do
      pending("Incomplete")
      # describe 'all string queries' do
      #   before :each do
      #     @results = Card.search('v v v', Slot.first)
      #     @cards = cards_from_result(@results)
      #     @columns = @results.keys.flatten.uniq.sort
      #   end
    
      #   it 'finds results in four categories' do
      #     @expected = (%w(Name Terminality Archetype Card\ Type)).sort
          
      #     expect(@columns.length).to eq(4)
      #     expect(@columns).to eq(@expected)
      #   end
    
      #   it 'only displays results with a hit against all supplied queries' do
      #     @lengths = []
      #     @results.keys.each do |set|
      #       @lengths << set.to_a.length
      #     end
          
      #     expect(@lengths).to all(be 2)
      #   end
      # end
      
      # describe 'mixed string and numeric queries' do
      # end
    end
  end

  # describe 'chained queries' do
    # before :each do
    #   @results = Card.search('v v', Slot.first)
    #   @cards = cards_from_result(@results)
    #   @columns = @results.keys.flatten.uniq.sort
    # end

    # it 'finds results in four categories' do
    #   @expected = %w(Name Terminality Archetype Strategy).sort
    #   expect(@columns).to eq(@expected)
    # end

    # it 'finds one \'name\' result' do
    #   expect(@columns).to include('Name')
    # end
    
    # it 'only displays results with a hit against all supplied queries' do
    #   @lengths = []
    #   @results.keys.each do |set|
    #     @lengths << set.to_a.length
    #   end
      
    #   expect(@lengths).to all(be 1)
    # end
  # end

  # describe 'Multi-query search' do
  #   before :each do
  #     @results = Card.search('v 3', Slot.first)
  #     @cards = cards_from_result(@results)
  #   end

  #   it 'finds three unique matching cards' do
  #     expect(@cards.count).to eq(3)
  #   end
  # end

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
