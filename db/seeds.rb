require 'slots_helper'

# Cards with using new two-database system
# card = Card.create!(
#                 name: 'Cellar',
#                 image_url: 'http://wiki.dominionstrategy.com/images/thumb/1/1c/Cellar.jpg/200px-Cellar.jpg',
#                 cost: 2
#             )
# Create Keyword instances
def self.create_keyword_instance(name, card)
    case name.capitalize
    when 'Action'
        Keyword.create!({
            name: 'Action',
            type: 'Card Type',
            description: 'Standard card type',
            card: card
        })
    when 'Reaction'
        Keyword.create!({
            name: 'Reaction',
            type: 'Card Type',
            description: 'Can be played after another player plays an Attack card',
            card: card
        })
    when 'Attack' 
        Keyword.create!({
            name: 'Attack',
            type: 'Card Type',
            description: 'Causes a negative effect to all other players.',
            card: card
        })
    when 'Base1' 
        Keyword.create!({
            name: 'Base (1st Edition)',
            type: 'Expansion',
            description: 'First release of Dominion (2008).',
            card: card
        })
    when 'Sifter' 
        Keyword.create!({
            name: 'Sifter',
            type: 'Archetype',
            description: 'Enables players to cycle through junk cards in their deck faster.',
            card: card
        })
    when 'Sifter' 
        Keyword.create!({
            name: 'Non-Terminal',
            type: 'Terminality',
            description: 'Additional Action cards can be played after this card.',
            card: card
        })
    else
        raise "Invalid keyword creation request. Params name:#{name} card:#{card}"
    end
end

def self.assign_keyword(keywords, card)
    keywords.split(', ').each do |kw|
        create_keyword_instance(kw, card)
    end
end


# 2 Cost cards >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Card.create!(name: "Cellar",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/1/1c/Cellar.jpg/200px-Cellar.jpg",
            cost: 2,
            types: "Action",
            category: "Sifter",
            expansion: "Base",
            strategy: "",
            terminality: "Non-Terminal")

Card.create!(name: "Chapel",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/2/29/Chapel.jpg/200px-Chapel.jpg",
            cost: 2,
            types: "Action",
            category: "Trasher",
            expansion: "Base",
            strategy: "Trashing",
            terminality: "Terminal")

Card.create!(name: "Moat",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/f/fe/Moat.jpg/200px-Moat.jpg",
            cost: 2,
            types: "Action, Reaction",
            category: "",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal")

# 3 Cost cards>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Card.create!(name: "Chancellor",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/b/b7/Chancellor.jpg/200px-Chancellor.jpg",
            cost: 3,
            types: "Action",
            category: "Deck Discarder",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal Silver")

Card.create!(name: "Village",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/5/5a/Village.jpg/200px-Village.jpg",
            cost: 3,
            types: "Action",
            category: "Village/Splitter",
            expansion: "Base",
            strategy: "Engine",
            # terminality: "Village")
            terminality: "Non-Terminal")
Card.create!(name: "Woodcutter",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/d/d6/Woodcutter.jpg/200px-Woodcutter.jpg",
            cost: 3,
            types: "Action",
            category: "+Buy",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal Silver")
Card.create!(name: "Workshop",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/5/50/Workshop.jpg/200px-Workshop.jpg",
            cost: 3,
            types: "Action",
            category: "Gainer",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal")
# 4 cost cards>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Card.create!(name: "Bureaucrat",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/4/4d/Bureaucrat.jpg/200px-Bureaucrat.jpg",
            cost: 4,
            types: "Action, Attack",
            category: "Gainer",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal")

Card.create!(name: "Feast",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/9/9c/Feast.jpg/200px-Feast.jpg",
            cost: 4,
            types: "Action",
            category: "One-shot",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal")


Card.create!(name: "Gardens",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/8/8c/Gardens.jpg/200px-Gardens.jpg",
            cost: 4,
            types: "Victory",
            category: "",
            expansion: "Base",
            strategy: "Rush, alt-VP",
            terminality: "")


Card.create!(name: "Militia",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/a/a0/Militia.jpg/200px-Militia.jpg",
            cost: 4,
            types: "Action, Attack",
            category: "Handsize Attack",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal Silver")


Card.create!(name: "Moneylender",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/7/70/Moneylender.jpg/200px-Moneylender.jpg",
            cost: 4,
            types: "Action",
            category: "Trasher, Trash-For-Benefit",
            expansion: "Base",
            strategy: "Trashing",
            terminality: "Terminal")


Card.create!(name: "Remodel",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/2/2e/Remodel.jpg/200px-Remodel.jpg",
            cost: 4,
            types: "Action",
            category: "Trasher, Trash-For-Benefit",
            expansion: "Base",
            strategy: "Trashing",
            terminality: "Terminal")


Card.create!(name: "Smithy",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/3/36/Smithy.jpg/200px-Smithy.jpg",
            cost: 4,
            types: "Action",
            category: "Smithies",
            expansion: "Base",
            strategy: "Big Money, Engine",
            terminality: "Terminal Draw")


Card.create!(name: "Spy",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/c/cb/Spy.jpg/200px-Spy.jpg",
            cost: 4,
            types: "Action, Attack",
            category: "Deck Inspection Attack",
            expansion: "Base",
            strategy: "",
            terminality: "Cantrip")


Card.create!(name: "Thief",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/f/f5/Thief.jpg/200px-Thief.jpg",
            cost: 4,
            types: "Action, Attack",
            category: "Trashing Attack",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal")


Card.create!(name: "Throne Room",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/d/d1/Throne_Room.jpg/200px-Throne_Room.jpg",
            cost: 4,
            types: "Action",
            category: "Throne Room",
            expansion: "Base",
            strategy: "",
            terminality: "")


# 5 cost cards>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Card.create!(name: "Council Room",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/e/e0/Council_Room.jpg/200px-Council_Room.jpg",
            cost: 5,
            types: "Action",
            category: "",
            expansion: "Base",
            strategy: "Big Money, Engine",
            terminality: "Terminal Draw")


Card.create!(name: "Festival",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/e/ec/Festival.jpg/200px-Festival.jpg",
            cost: 5,
            types: "Action",
            category: "Village, +Buy, Virtual Coin",
            expansion: "Base",
            strategy: "",
            terminality: "Non-Terminal")


Card.create!(name: "Laboratory",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/0/0c/Laboratory.jpg/200px-Laboratory.jpg",
            cost: 5,
            types: "Action",
            category: "Lab Variants",
            expansion: "Base",
            strategy: "Engine",
            terminality: "Non-Terminal")


Card.create!(name: "Library",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/9/98/Library.jpg/200px-Library.jpg",
            cost: 5,
            types: "Action",
            category: "",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal Draw")


Card.create!(name: "Market",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/7/7e/Market.jpg/200px-Market.jpg",
            cost: 5,
            types: "Action",
            category: "+Buy",
            expansion: "Base",
            strategy: "",
            terminality: "Cantrip")


Card.create!(name: "Mine",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/8/8e/Mine.jpg/200px-Mine.jpg",
            cost: 5,
            types: "Action",
            category: "Trash-For-Benefit, Trasher",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal")


Card.create!(name: "Witch",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/f/f3/Witch.jpg/200px-Witch.jpg",
            cost: 5,
            types: "Action, Attack",
            category: "Curser",
            expansion: "Base",
            strategy: "",
            terminality: "Terminal Draw")

# 6 Cost Cards >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Card.create!(name: "Adventurer",
            image_url: "http://wiki.dominionstrategy.com/images/thumb/7/71/Adventurer.jpg/200px-Adventurer.jpg",
            cost: 6,
            types: "Action",
            category: "Digger",
            expansion: "Base",
            strategy: "Engine",
            terminality: "Terminal Draw")

10.times do
  Slot.create!(image_url: "http://vignette2.wikia.nocookie.net/dominioncg/images/6/65/Randomizer.jpg/revision/latest?cb=20100224111917")
end


def self.get_base_game_info(card)
    {
        name: 'Base (1st Edition)',
        type: 'Expansion',
        description: 'First release of Dominion',
        card: card
    } 
end