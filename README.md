[View Live Version Here](https://dset-app.herokuapp.com/)

# DSet: A Dominion Card Database

DSet is a prototype card database system for the board game [Dominion](https://boardgamegeek.com/boardgame/3). It combines the features of a fuzzy search, chainable search, and Multi-Category search into a single system. The core work of the project has concentrated on the development of the app's search functionality, with the ultimate goal of functioning as a card lookup and customizable randomizer for Dominion enthusiasts.

**Work in Progress**

## Feature Overview
### Chainable Search

Each string delimited by a space is treated as a filter to refine searches down to only results that match all supplied queries.
*Example: The query "v 3" will search for cards containing fields containing the letter v, and then refine that result set further to only those that also
have a cost of 3.*

### Fuzzy Search

Each subquery is evaluated as a "fuzzy" query, enabling matching of non-consecutive characters for faster lookup.
*Example: The query "vlg" will match with the card name "Village"*

### Multi-Category Search

Each query is evaluated across multiple possible categories, with results displayed to the user by the terms and categories on which they are matched.
*Example: See below*

![Multi-Cat Example](https://i.imgur.com/WomyNrE.png "Multi-Category Result Display Example")

### Livesearch
Searches are instantaneous and update as the user types in their queries.
