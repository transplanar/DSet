# frozen_string_literal: true

# require "awesome_print"
# include SlotsHelper

class Card < ActiveRecord::Base
  extend SlotsHelper

  has_and_belongs_to_many :slots
  has_many :descriptors

  # TODO: fix to assign to slot

  def self.search(queries_string, _)
    return [] if queries_string.blank?

    query_array = queries_string.to_s.split
    formatted_queries = format_multi_char_queries(query_array)
    matches = get_matches(formatted_queries)
    # FIXME: Better way to cull matches that don't have hit with all queries?
    matches = matches.select { |_, v| v[:terms].length >= query_array.length }

    matches.group_by { |_, v| v[:columns] }
  end

  private_class_method def self.format_multi_char_queries(arr)
    result = []
    arr.each do |elem|
      if numeric?(elem)
        result << elem
      else
        result << format_string_query(elem)
      end
    end

    result
  end

  private_class_method def self.format_string_query(query)
    return query if(query.length < 2)

    formatted_query = '.*'

    query.split('').each do |ch|
      formatted_query += (ch + '.*')
    end

    formatted_query
  end

  private_class_method def self.get_matches(subqueries)
    match_data = {}

    subqueries.each do |query|
      result = get_card_subset(query, match_data)

      match_data = result.nil? ? match_data : result
    end

    match_data
  end

  # TODO: Split this into separate methods
  private_class_method def self.get_card_subset(query, match_data)
    new_match_data = {}

    if(match_data.empty?)
      card_set = Card.all
    else
      card_set = Card.where(name: match_data.keys)
    end

    if numeric?(query)
      matched_cards = card_set.where(cost: query)

      matched_cards.each do |card|
        merge_match_data(match_data, new_match_data, card, 'Cost', query)
      end
    else
      matched_cards = card_set.where('name ~* :pat', pat: query).distinct

        matched_cards.each do |card|
          merge_match_data(match_data, new_match_data, card, 'Name', card[:name])
        end


        match_data = (new_match_data.any? ? new_match_data : match_data)

        descriptor_set = Descriptor.where(Descriptor.arel_table[:card_id].in card_set.pluck(:id) ).distinct

        descriptor_matches = descriptor_set.where('name ~* :pat', pat: query).distinct

        descriptor_matches.each do |kw|
            merge_match_data(match_data, new_match_data, kw.card, kw.category, kw.name)
        end
    end

    return new_match_data
  end

# FIXME: move to helper?
  private_class_method def self.numeric?(str)
    str.to_s.delete('%').match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil
  end

# FIXME: move to helper?
  private_class_method def self.merge_match_data(match_data, new_match_data, card, column, term)
    new_match_data[card.name] = new_match_data[card.name]!=nil ? new_match_data[card.name] : {}
    new_match_data[card.name][:card] = card
    new_match_data[card.name][:columns] = merge_result_hash(match_data, card.name, :columns, column)
    new_match_data[card.name][:terms] = merge_result_hash(match_data, card.name, :terms, term)
  end

  # FIXME: move to helper?
  private_class_method def self.merge_result_hash(hsh, key, sub_key, new_elem)
    result = {}

    if hsh[key].nil?
      result = [new_elem]
    else
      if hsh[key][sub_key].nil?
        result = [new_elem]
      else
        result = (hsh[key][sub_key].include?(new_elem) ?
          hsh[key][sub_key] : hsh[key][sub_key].push(new_elem))
      end
    end

    result
  end
end
