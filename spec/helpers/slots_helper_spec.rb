require 'rails_helper'

RSpec.describe SlotsHelper, type: :module do
  include SlotsHelper

  before :each do
    load Rails.root + "db/seeds.rb"
    @collection = Card.where('name LIKE ?', '%a%').limit(10)
    @columns = []
    @terms = []
    3.times do |i|
      @columns << "FakeColumn#{i}"
      @terms << "FakeTerm#{i}"
    end

    @mock_results = {}

    @collection.each do |card|
      @mock_results[card.name] = {
        card: card,
        terms: @terms,
        columns: @columns
      }
    end

    @sample_card = @collection.first

    @mock_results = @mock_results.group_by { |_, v| v[:columns] }
  end

  describe 'functions' do
    describe 'cards_from_result' do
      it 'should retrieve the correct cards' do
        @cards = cards_from_result(@mock_results)

        expect(@cards).to eq(@collection)
      end
    end

    describe 'columns_from_result' do
      it 'should retrieve correct columns' do
        @columns = columns_from_result(@mock_results)
        @expected_columns = []

        3.times do |i|
          @expected_columns << "FakeColumn#{i}"
        end

        expect(@columns.size).to eq(3)
        expect(@columns).to eq(@expected_columns)
      end
    end

    describe 'names_from_result' do
      it 'should get names of all cards in result hash' do
        @names = names_from_result(@mock_results)

        expect(@names.size).to eq(@collection.size)
        expect(@names.first).to eq('Cellar')
      end
    end
  end
end
