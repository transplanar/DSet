require 'rails_helper'

RSpec.describe CardKeyword, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"

    # before :each do
    #     load Rails.root + "db/seeds.rb"
    # end
    
    describe 'when validating fields' do
        # before :each do
        #     kw = CardKeyword.create({})
        # end
        
        it 'should throw exception if any fields are blank' do
            p "Errors #{CardKeyword.new.errors.first}"
            expect(CardKeyword.new.errors.any?).to be_truthy 
        end
        
        # context 'each keyword' do
        #     it 'should have at a card associated with it' do
        #         blanks = CardKeyword.where('card_id IS ?', nil)
        #         expect(blanks.count).to be_empty
        #     end
        # end
    end
end
