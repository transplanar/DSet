require 'slots_helper'

# TODO support aliases
# TODO add terminal draw
# TODO store card images in assets folder
def create_keyword_instance(name, card)
    case name.downcase
    # Expansions
    when 'Base'.downcase
        CardKeyword.create!({
            name: 'Base (1st Edition)',
            category: 'Expansion',
            description: 'First release of Dominion (2008).',
            card: card
        })
    # Card types
    when 'Action'.downcase
        CardKeyword.create!({
            name: 'Action',
            category: 'Card Type',
            description: 'Standard card type',
            card: card
        })
    when 'Reaction'.downcase
        CardKeyword.create!({
            name: 'Reaction',
            category: 'Card Type',
            description: 'Can be played after another player plays an Attack card',
            card: card
        })
    when 'Attack'.downcase
        CardKeyword.create!({
            name: 'Attack',
            category: 'Card Type',
            description: 'Causes a negative effect to all other players.',
            card: card
        })
    when 'Victory'.downcase
        CardKeyword.create!({
            name: 'Victory',
            category: 'Card Type',
            description: 'Award victory points at the end of the game.',
            card: card
        })
    # Subtypes
    # Attack Subtypes
    when 'Handsize Attack'.downcase
        CardKeyword.create!({
            name: 'Handsize Attack',
            category: 'Subtype',
            description: 'Forces players to discard cards.',
            card: card
        })
    when 'Deck Inspection Attack'.downcase
        CardKeyword.create!({
            name: 'Deck Inspection Attack',
            category: 'Subtype',
            description: 'Allows you to see other player\'s cards and choose whether they keep or discard them.',
            card: card
        })
    when 'Trashing Attack'.downcase
        CardKeyword.create!({
            name: 'Trashing Attack',
            category: 'Subtype',
            description: 'Forces other players to trash cards.',
            card: card
        })
    when 'Curser'.downcase
        CardKeyword.create!({
            name: 'Curser',
            category: 'Subtype',
            description: 'Gives other players curse cards.',
            card: card
        })


    # Trasher Subtypes
    when 'Trash-For-Benefit'.downcase
        CardKeyword.create!({
            name: 'Trash-For-Benefit',
            category: 'Subtype',
            description: 'Allow you to trash a card and gain an additional benefit.',
            card: card
        })

    # Archetypes
    when 'Blocker'.downcase
        CardKeyword.create!({
            name: 'Blocker',
            category: 'Archetype',
            description: 'Nullifies the effects of Attacks against you.',
            card: card
        })
    when 'Sifter'.downcase
        CardKeyword.create!({
            name: 'Sifter',
            category: 'Archetype',
            description: 'Enables players to cycle through junk cards in their deck faster.',
            card: card
        })

    when 'Trasher'.downcase
        CardKeyword.create!({
            name: 'Trasher',
            category: 'Archetype',
            description: 'Allows player to remove one or more cards from their deck.',
            card: card
        })
    when 'Deck Discarder'.downcase
        CardKeyword.create!({
            name: 'Deck Discarder',
            category: 'Archetype',
            description: 'Allows you to discard your deck, allowing you to draw recently bought cards more quickly.',
            card: card
        })
    when '+Buy'.downcase
        CardKeyword.create!({
            name: '+Buy',
            category: 'Archetype',
            description: 'Grants you one or more additional Buys',
            card: card
        })
    when 'Gainer'.downcase
        CardKeyword.create!({
            name: 'Gainer',
            category: 'Archetype',
            description: 'Allows you to obtain a Card during your Action Phase without consuming a Buy.',
            card: card
        })
    when "One-Shot".downcase
        CardKeyword.create!({
            name: 'One-Shot',
            category: 'Archetype',
            description: 'Card that can only be played once, then is removed from your deck.',
            card: card
        })
    when 'Smithies'.downcase
        CardKeyword.create!({
            name: 'Smithies',
            category: 'Archetype',
            description: 'Allows you to draw 2 or more cards.',
            card: card
        })
    when 'Virtual Coin'.downcase
        CardKeyword.create!({
            name: 'Virtual Coin',
            category: 'Archetype',
            description: 'Non-Treasure card that gives Coins on the turn it is played.',
            card: card
        })
    when 'Throne Room'.downcase, 'Duplicator'.downcase
        CardKeyword.create!({
            name: 'Throne Room',
            category: 'Archetype',
            description: 'Duplicates the effect of another card.',
            card: card
        })
    when 'Draw'.downcase
      CardKeyword.create!({
        name: 'Draw',
        category: 'Archetype',
        description: 'Draws you two or more cards.',
        card: card
      })
    when 'Digger'.downcase
      CardKeyword.create!({
        name: 'Digger',
        category: 'Archetype',
        description: 'Searches the deck for a particular card type',
        card: card
      })
    # Terminality
    when 'Non-Terminal'.downcase
        CardKeyword.create!({
            name: 'Non-Terminal',
            category: 'Terminality',
            description: 'Refunds the Action spent to use this card, allowing additional Action cards to be played.',
            card: card
        })
    when 'Terminal'.downcase
        CardKeyword.create!({
            name: 'Terminal',
            category: 'Terminality',
            description: 'Consumes the Action spent to use this card.',
            card: card
        })
    when 'Village'.downcase, 'Splitter'.downcase
        if(CardKeyword.where(name: 'Splitter / Village').any?)
            return
        end
        
        CardKeyword.create!({
            name: 'Splitter / Village',
            category: 'Terminality',
            description: 'Refunds the Action spent to use this card plus provides one or more additional Actions.',
            card: card
        })
    when 'Cantrip'.downcase
        CardKeyword.create!({
            name: 'Cantrip',
            category: 'Terminality',
            description: 'Refunds the Action spent to use this card and draws you an additional card, effectively taking up no space in your deck.',
            card: card
        })
    # Strategies
    when 'Trashing'.downcase, 'Deckthinning'.downcase
        CardKeyword.create!({
            name: 'Deckthinning / Trashing',
            category: 'Strategy',
            description: 'Removing as many low-value cards from your deck as possible to more consistently draw your strongest cards.',
            card: card
        })
    when 'Engine'.downcase
        CardKeyword.create!({
            name: 'Engine',
            category: 'Strategy',
            description: 'Focusing on extra actions and card draw to build towards big turns that combo multiple effects.',
            card: card
        })
    when 'Rush'.downcase
        CardKeyword.create!({
            name: 'Rush',
            category: 'Strategy',
            description: 'Attempt to end the game early by depleting victory card piles as fast as possible.',
            card: card
        })
    when 'Alt-VP'.downcase
        CardKeyword.create!({
            name: 'Alt-VP',
            category: 'Strategy',
            description: 'Focus on obtaining victory points through card effects rather than traditional victory cards.',
            card: card
        })
    when 'Big Money'.downcase
        CardKeyword.create!({
            name: 'Big Money',
            category: 'Strategy',
            description: 'Focus on high-value Treasure cards and card draw.',
            card: card
        })
    else
        raise "Invalid keyword creation request. Params name: '#{name}' card: '#{card}'"
    end
end

def assign_keywords(keywords, card)
    keywords.each do |kw|
        create_keyword_instance(kw, card)
    end
end

base_url = "http://wiki.dominionstrategy.com/images/thumb/"

# 2 Cost Cards
card = Card.create!(name: "Cellar",
            image_url: base_url + "1/1c/Cellar.jpg/200px-Cellar.jpg",
            cost: 2)

assign_keywords(%w(Action Sifter Base Non-Terminal), card)

card = Card.create!(name: "Chapel",
            image_url: base_url + "2/29/Chapel.jpg/200px-Chapel.jpg",
            cost: 2)

assign_keywords(%w(Action Trasher Base Trashing Terminal), card)

card = Card.create!(name: "Moat",
            image_url: base_url + "f/fe/Moat.jpg/200px-Moat.jpg",
            cost: 2)

assign_keywords(%w(Action Reaction Blocker Base Terminal), card)

# 3 Cost Cards
card = Card.create!(name: "Chancellor",
            image_url: base_url + "b/b7/Chancellor.jpg/200px-Chancellor.jpg",
            cost: 3)

assign_keywords(%w(Action Deck\ Discarder Base Virtual\ Coin Terminal), card)

card = Card.create!(name: "Village",
            image_url: base_url + "5/5a/Village.jpg/200px-Village.jpg",
            cost: 3)

assign_keywords(%w(Action Splitter Village Base Non-Terminal Engine), card)

card = Card.create!(name: "Woodcutter",
            image_url: base_url + "d/d6/Woodcutter.jpg/200px-Woodcutter.jpg",
            cost: 3)

assign_keywords(%w(Action Base +Buy Virtual\ Coin Engine Terminal), card)

card = Card.create!(name: "Workshop",
            image_url: base_url + "5/50/Workshop.jpg/200px-Workshop.jpg",
            cost: 3)

assign_keywords(%w(Action Base Gainer Terminal), card)

# Cost 4 Cards
card = Card.create!(name: "Bureaucrat",
            image_url: base_url + "4/4d/Bureaucrat.jpg/200px-Bureaucrat.jpg",
            cost: 4)

assign_keywords(%w(Action Base Attack Gainer Terminal), card)

card = Card.create!(name: "Feast",
            image_url: base_url + "9/9c/Feast.jpg/200px-Feast.jpg",
            cost: 4)

assign_keywords(%w(Action Base One-Shot Terminal), card)

card = Card.create!(name: "Gardens",
            image_url: base_url + "8/8c/Gardens.jpg/200px-Gardens.jpg",
            cost: 4)

assign_keywords(%w(Base Victory Rush alt-VP Terminal), card)

card = Card.create!(name: "Militia",
            image_url: base_url + "a/a0/Militia.jpg/200px-Militia.jpg",
            cost: 4)

assign_keywords(%w(Base Action Attack Handsize\ Attack Virtual\ Coin Terminal), card)

card = Card.create!(name: "Moneylender",
            image_url: base_url + "7/70/Moneylender.jpg/200px-Moneylender.jpg",
            cost: 4)

assign_keywords(%w(Base Action Trasher Trash-For-Benefit Trashing Terminal), card)

card = Card.create!(name: "Remodel",
            image_url: base_url + "2/2e/Remodel.jpg/200px-Remodel.jpg",
            cost: 4)

assign_keywords(%w(Base Action Trasher Trash-For-Benefit Trashing Terminal), card)

card = Card.create!(name: "Smithy",
            image_url: base_url + "3/36/Smithy.jpg/200px-Smithy.jpg",
            cost: 4)

assign_keywords(%w(Base Action Smithies Big\ Money Engine Terminal), card)

card = Card.create!(name: "Spy",
            image_url: base_url + "c/cb/c/cb/Spy.jpg/200px-Spy.jpg",
            cost: 4)

assign_keywords(%w(Base Action Attack Deck\ Inspection\ Attack Cantrip), card)

card = Card.create!(name: "Thief",
            image_url: base_url + "f/f5/Thief.jpg/200px-Thief.jpg",
            cost: 4)

assign_keywords(%w(Base Action Attack Trashing\ Attack Terminal), card)

card = Card.create!(name: "Throne Room",
            image_url: base_url + "d/d1/Throne_Room.jpg/200px-Throne_Room.jpg",
            cost: 4)

assign_keywords(%w(Base Action Throne\ Room Duplicator Terminal), card)

# 5 Cost Cards
card = Card.create!(name: "Council Room",
            image_url: base_url + "e/e0/Council_Room.jpg/200px-Council_Room.jpg",
            cost: 5)

assign_keywords(%w(Base Action Big\ Money Engine Terminal), card)

card = Card.create!(name: "Festival",
            image_url: base_url + "e/ec/Festival.jpg/200px-Festival.jpg",
            cost: 5)

assign_keywords(%w(Base Action Village +Buy Virtual\ Coin Engine Non-Terminal), card)

card = Card.create!(name: "Laboratory",
            image_url: base_url + "0/0c/Laboratory.jpg/200px-Laboratory.jpg",
            cost: 5)

assign_keywords(%w(Base Action Engine Non-Terminal), card)

card = Card.create!(name: "Library",
            image_url: base_url + "9/98/Library.jpg/200px-Library.jpg",
            cost: 5)

assign_keywords(%w(Base Action Engine Terminal), card)

card = Card.create!(name: "Market",
            image_url: base_url + "7/7e/Market.jpg/200px-Market.jpg",
            cost: 5)

assign_keywords(%w(Base Action +Buy Cantrip), card)

card = Card.create!(name: "Mine",
            image_url: base_url + "8/8e/Mine.jpg/200px-Mine.jpg",
            cost: 5)

assign_keywords(%w(Base Action Trash-For-Benefit Trasher Terminal), card)

card = Card.create!(name: "Witch",
            image_url: base_url + "f/f3/Witch.jpg/200px-Witch.jpg",
            cost: 5)

assign_keywords(%w(Base Action Attack Curser Draw Terminal), card)

card = Card.create!(name: "Adventurer",
            image_url: base_url + "7/71/Adventurer.jpg/200px-Adventurer.jpg",
            cost: 6)

assign_keywords(%w(Base Digger Engine Draw Terminal), card)

10.times do
  Slot.create!(image_url: "http://vignette2.wikia.nocookie.net/dominioncg/images/6/65/Randomizer.jpg/revision/latest?cb=20100224111917")
end
