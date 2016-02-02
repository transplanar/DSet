class SlotController < ApplicationController
  def new
    # @filter_rules = []
  end

  def create
    # @filter_rules = []
  end

  def update
    @slot = Slot.find(params[:slot_id])
    @slot.update_attribute(:queries, params[:search])

    # puts "SLOT SEARCH TERMS SET TO #{slot.queries}"
  end

  def edit
    @slot = Slot.find(params[:slot_id])
  end

  # def save_filter_rule rule
  def save_filter_rule
    puts "MATCH PARAM #{params[:match]} / #{@filter_rules}"
    slot = Slot.find(params[:slot_id])

    # TODO convert queries params into SQL
    # slot.update_attribute(:queries) =


    # @filter_rules << params[:match]


    # t.string :queries
  end

end
