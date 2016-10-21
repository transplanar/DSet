include SlotsHelper

class SlotsController < ApplicationController
  def show
    @slot = Slot.find(params[:id])

    # @results, @matched_terms = Card.search(params[:search], @slot)
    @results = Card.search(params[:search], @slot)

    unless @slot.sql_prepend.blank?
      @saved_filters = @slot.filters_humanized.split(', ')
    end
  end

  def assign_card
    @slot = Slot.find(params[:slot_id])

    card = Card.find(params[:id])

    direct_card_assign(@slot, card)

    redirect_to slot_path(@slot)
  end

  def assign_filter
    @slot = Slot.find(params[:slot_id])

    if @slot[:sql_prepend].blank?
      @slot.update_attribute(:sql_prepend, Card.send( "_#{params[:col]}", params[:term]).to_sql)
      @slot.update_attribute(:filters_humanized, "#{params[:col]}: #{params[:term]}")
    else
      append_term = Card.send( "_#{params[:col]}", params[:term] ).to_sql.gsub(/.*?(?=\()/im, "")

      unless @slot.sql_prepend.include? append_term
        @slot.update_attribute(:sql_prepend, @slot.sql_prepend + " AND " + append_term )
        @slot.update_attribute(:filters_humanized, "#{@slot.filters_humanized}, #{params[:col]}: #{params[:term]}")
      end
    end

    @slot.cards = Card.find_by_sql(@slot.sql_prepend)

    redirect_to slot_path(@slot)
  end

  def delete_filter
    @slot = Slot.find(params[:slot_id])

    sql_queries = @slot.filters_humanized.split(', ')

    # TODO error check for API?
    sql_queries.delete(params[:pair])

    pair_hashes = []

    sql_queries.each do |pair|
      pair_arr = pair.split(': ')

      pair_hashes << Hash[*pair_arr]
    end

    unless sql_queries.count > 0
      @slot.update_attribute(:sql_prepend, "")
      @slot.update_attribute(:filters_humanized, "")
    else
      pair_hashes.each do |pair|
        pair.each do |col, term|
          if pair == pair_hashes.first
            @slot.update_attribute(:sql_prepend, Card.send( "_#{col}", term).to_sql)
            @slot.update_attribute(:filters_humanized, "#{col}: #{term}")
          else
            append_term = Card.send( "_#{col}", term ).to_sql.gsub(/.*?(?=\()/im, "")

            @slot.update_attribute(:sql_prepend, @slot.sql_prepend + " AND " + append_term )
            @slot.update_attribute(:filters_humanized, "#{@slot.filters_humanized}, #{col}: #{term}")
          end
        end
      end
    end

    @slot.cards = Card.all

    redirect_to slot_path(@slot)
  end
end
