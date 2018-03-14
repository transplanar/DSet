require 'rails_helper'

# TODO rename/move to better spot
RSpec.describe Card, type: :model do
  include SlotsHelper

  before :each do
    load Rails.root + "db/seeds.rb"
  end

  context 'card search' do
    describe 'single query searches using a' do
      describe 'character' do
        it 'should include expected cards' do
          @results = Card.search('p', Slot.first)
          @names = names_from_result(@results)

          @expected_names = %w[Chapel Workshop Spy Gardens Market Village]

          expect(@names.sort).to eq(@expected_names.sort)
        end
      end
      describe 'number' do
        it 'should include expected cards' do
          @results = Card.search(3, Slot.first)
          @names = names_from_result(@results)

          @expected_names = %w[Village Woodcutter Workshop Chancellor]
          expect(@names.sort).to eq(@expected_names.sort)
        end
      end
      describe 'string' do
        it "should match with the 'Village' card" do
          @results = Card.search('vlg', Slot.first)
          @names = names_from_result(@results)

          @expected_names = %w[Village]

          expect(@names).to eq(@expected_names)
        end
      end
    end

    describe 'chained queries using' do
      describe 'a number and' do
        before :each do
          @query = '3'
        end

        describe 'character' do
          it 'should include expected cards' do
            @query += ' v'
            @results = Card.search(@query, Slot.first)
            @names = names_from_result(@results)
            @expected_names = %w[Village Chancellor Woodcutter]

            expect(@names.sort).to eq(@expected_names.sort)
          end
        end
        describe 'number' do
          it 'should produce zero results' do
            @query += ' 4'
            @results = Card.search(@query, Slot.first)

            expect(@results).to be_empty
          end
        end
        describe 'string' do
          it 'should include expected cards' do
            @query += ' cr'
            @results = Card.search(@query, Slot.first)
            @names = names_from_result(@results)
            @expected_names = %w[Chancellor Woodcutter]

            expect(@names.sort).to eq(@expected_names.sort)
          end
        end
      end

      describe 'a character and' do
        describe 'character' do

        end
        describe 'string' do

        end
      end

      describe 'a string and string' do
        it 'should include expected cards' do
          @query = 'trsh mne'
          @results = Card.search(@query, Slot.first)
          @names = names_from_result(@results)
          @expected_names = %w[Moneylender Mine]

          expect(@names.sort).to eq(@expected_names.sort)
        end
      end

      describe 'when supplied x queries' do
        describe 'should match in x columns' do
          it 'when supplied unique queries' do
            @query = 'trsh mne'
            @num_queries = @query.split(' ').size
            @results = Card.search(@query, Slot.first)
            @lengths = @results.keys.map(&:length)

            expect(@lengths).to all(be >= @num_queries)
          end

          it 'when supplied identical queries' do
            @query = 'v v v'
            @num_queries = @query.split(' ').size
            @results = Card.search(@query, Slot.first)
            @lengths = @results.keys.map(&:length)

            expect(@lengths).to all(be >= @num_queries)
          end
        end
      end

      describe 'three or more chained queries' do
        it 'should include expected cards' do
          @query = 'trsh mne 5'
          @results = Card.search(@query, Slot.first)
          @names = names_from_result(@results)
          @expected_names = %w[Mine]

          expect(@names.sort).to eq(@expected_names.sort)
        end
      end
    end
  end

  describe 'card search' do
    context 'single query' do
      describe 'against a character' do
        before :each do
          @results = Card.search('c', Slot.first)
          @names = names_from_result(@results)
        end

        it "should include 'Cellar' as a result" do
          expect(@names).to include('Cellar')
        end
      end

      describe 'against a string' do
        before :each do
          @results = Card.search('vlg', Slot.first)
          @names = names_from_result(@results)
        end

        it "should include 'Village' as a result" do
          expect(@names).to include('Village')
        end
      end

      describe 'against a number' do
        before :each do
          @results = Card.search(3, Slot.first)
          @names = names_from_result(@results)
        end

        it 'should include expected cards' do
          expected_names = %w[Village Woodcutter Workshop Chancellor]
          expect(@names.sort).to eq(expected_names.sort)
        end
      end
    end

    # context 'string search' do
    #   it "'Cellar' should appear in a name search" do
    #     expect(@cards).to include(@test_card)
    #   end

    #   it "cellar should NOT appear in a cost search" do
    #     if @results['cost'].nil?
    #       @results['cost'] = {}
    #     end

    #     expect(@results['cost']).not_to include(@test_card)
    #     expect(@results['cost']).to be_empty
    #   end

    #   it 'cellar should NOT appear in an irrelevant search' do
    #     @results = Card.search('x', Slot.first)
    #     @cards = cards_from_result(@results)

    #     expect(@cards).not_to include(@test_card)
    #   end
    # end
  end

  describe 'chained queries' do
    describe 'numeric/numeric queries' do
      it 'should produce no results' do
        @results = Card.search('3 4', Slot.first)

        expect(@results).to be_empty
      end
    end

    describe 'number/character queries' do
      before :each do
        @results = Card.search('v 3', Slot.first)
        @cards = cards_from_result(@results)
      end

      it 'finds three unique matching cards' do
        expect(@cards.count).to eq(3)
      end

      it 'key element length should match number of supplied queries' do
        @key_lengths = []

        @results.each_key do |key|
          @key_lengths << key.to_a.length
        end

        expect(@key_lengths).to all(be 2)
      end

      it 'different query order should produce the same result' do
        @results2 = Card.search('3 v', Slot.first)
        @cards2 = cards_from_result(@results2)

        expect(@cards2.sort).to eq(@cards.sort)
      end
    end

    describe 'character/character queries' do
      describe 'duplicate queries' do
        before :each do
          @results = Card.search('v a', Slot.first)
          @cards = cards_from_result(@results)
          @columns = @results.keys.flatten.uniq.sort
        end

        it 'finds results in expected columns' do
          @expected_columns = %w[Name Archetype Card\ Type Expansion Strategy Subtype Terminality].sort

          expect(@columns).to eq(@expected_columns)
        end

        it 'only displays results with a hit against all supplied queries' do
          pending("Refactor required")
          @lengths = []
          @results.each_key do |set|
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
      # pending("Incomplete")
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

  # describe 'non-consecutive matching' do
  #   before :each do
  #     @results = Card.search('vlg', Slot.first)
  #   end
  #
  #   it 'should display \'village\' as first result' do
  #     result_values = values_from_results
  #     expect(result_values.first.name.downcase).to eq('village')
  #   end
  # end
end
