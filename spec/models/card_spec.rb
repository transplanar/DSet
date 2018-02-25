require 'rails_helper'

# TODO rename/move to better spot
RSpec.describe Card, type: :model do
  include SlotsHelper

  before :all do
    if Card.all.length < 1
      load Rails.root + "db/seeds.rb"
    end
  end
  
  describe 'database load' do
    it 'should preload all cards from database' do
      expect(Card.all.length).to eq(25)
    end
  end

  describe 'card search' do
    context 'single query' do
      describe 'against a character' do
        before :all do
          @results = Card.search('c', Slot.first)
          @cards = cards_from_result(@results)
          @names = names_from_result(@results)
          @columns = columns_from_result(@results).sort
        end
        
        it "should include 'Cellar' as a result" do
          expect(@names).to include('Cellar')
        end
        
        it 'should find 24 matches (base game)' do
          expect(@cards.length).to be(24)
        end
        
        it 'should match along 4 categories' do
          expect(@columns).to eq(%w(Archetype Card\ Type Subtype Strategy).sort)
        end
      end
      
      describe 'against a string' do
        before :all do
          @results = Card.search('cel', Slot.first)
          @cards = cards_from_result(@results)
          @names = names_from_result(@results)
          @columns = columns_from_result(@results).sort
        end
        
        
        it "should include 'Cellar' and 'Chancellor' in results" do
          expect(@names).to eq(%w(Chancellor Cellar).sort)
        end
        
        it 'should match along the \'Name\' category' do
          expect(@columns).to eq(%w(Name).sort)
        end
      end
      
      describe 'against a number' do
        before :all do
          @results = Card.search(3, Slot.first)
          @cards = cards_from_result(@results)
          @names = names_from_result(@results)
          @columns = columns_from_result(@results).sort
        end
        
        
        it "should include 'Cellar' and 'Chancellor' in results" do
          expect(@names).to eq(%w(Chancellor Village Woodcutter Workshop).sort)
        end
        
        it 'should match along the \'Name\' category' do
          expect(@columns).to eq(%w(Cost).sort)
        end
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
    
    describe 'numeric/character queries' do
      before :all do
        @results = Card.search('v 3', Slot.first)
        @cards = cards_from_result(@results)
        @names = names_from_result(@results).sort
        @columns = columns_from_result(@results).sort
        @expected_names = (%w(Chancellor Village Woodcutter)).sort
      end
  
      it "should include 'Cellar' and 'Chancellor' in results" do
          expect(@names).to eq(@expected_names)
      end
      
      it 'should match along the \'Name\' category' do
        expect(@columns).to eq(%w(Name Cost).sort)
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
      describe 'duplicate queries' do
        before :all do
          @results1 = Card.search('v', Slot.first)
          @results2 = Card.search('v v', Slot.first)
        end
    
      # FIXME sometimes fails for some mysterious reason
        it 'should ignore duplicate queries' do
          expect(@results1).to eq(@results2)
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
