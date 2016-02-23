## DSet: A Dominion Card Set Generator

This app simulates a (Dominion)[https://boardgamegeek.com/boardgame/36218/dominion] randomizer deck to produce a set of 10 cards to play a game of Dominion. It provides additional features defining what cards to include/exclude, search functionality, and the ability to set global rules for what expansions should be allowed and/or to enforce a spread of card costs.

author: Glen Cooney
Capstone for Bloc Full Stack Web Development Apprenticeship

###Features:
* Livesearch
* Multi-category search (in the style of Ubuntu's Unity search)
* Chainable search queries
* Fuzzy search (find by minimum number of characters)
* Autocomplete filters (scopes)

###What is a Randomizer?
Dominion is a deckbuilding game where players acquire cards over the course of play in order to combo their effects together and ultimately claim cards that will earn
them victory points. In each game, players have 10 stacks of 10 cards each they may buy from, which are randomly determined during setup (with a few cards that are included in every game). These 10 cards ("Kingdom Cards") are randomly chosen using the "Randomizer Deck," which contains a single copy of each of the Kingdom cards included in the game (25 total in the original retail set).

This app simulates the Randomizer deck, while giving the user more control over the types of cards that will be selected.

###Functionality Overview
Users can click on any of the ten card slots and feed them filtering criteria through its search bar. This will shrink the pool of acceptable cards for that slot, from
which a single card will be randomly chosen for that slot.

These criteria may include the name of a card, some attribute of the card (such as its cost, type, etc), or by other grouping categories defined by the community of
the (Dominion Strategy Wiki)[http://wiki.dominionstrategy.com]. The app performs a live search as you type, displaying potential autocomplete results for specific
filters as well as a list of cards organized by the category under which the term was matched (modeled after (Ubuntu's Unity search system)[http://linuxconfig.net/wp-content/uploads/2012/06/oneric_unity_dash.jpg])

####Query chaining
As of this writing (2.23.16), users may chain up to two search terms together separated by a comma. For example, "v, 3" will return three cards: Village (matched by name, type, and cost), Chancellor, and Woodcutter (the latter two matched by cost and terminality (terminal silver)).

####Filter Autocomplete
Users may click any of the "Matched filters" to autocomplete their search result. These will display as "saved filters," which can be cleared by clicking their link again.

####Direct Selection
Users may click any card in the slots page to directly select that card, assigning that singular card to that slot. This will discard all other search criteria. As of this writing (2.23.16), this can only be cleared by using "Clear Filters" from the slots index view.

####Card Generation
When desired filters and cards have been selected, simply go back to the card index and click the "Generate Cards" button to generate a random set of 10 Dominion cards.

###How to Use
1. Click a card to view that "slot"


###Future Development
This is an ongoing project. Future features include:
* "Infinite" query chaining
* Conditional filters
* Multi-slot filtering rules
* Improved filter term matching
* User profiles and decklist saving
* Links to card strategies
* Links to the "story" behind the creation of each card (by Donald X himself)
* Cards from all 9 Dominion expansions (including additional components)


###LEGAL
This an unofficial card search and randomizer app for the tabletop game Dominion (c) 2008 by Donald X. Vaccarino
