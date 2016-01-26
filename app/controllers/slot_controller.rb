class SlotController < ApplicationController
  def new
  end

  def create
  end

  def update
    @slot = Slot.find(params[:slot_id])
    @slot.update_attribute(:queries, params[:search])

    # puts "SLOT SEARCH TERMS SET TO #{slot.queries}"
  end

  def edit
    @slot = Slot.find(params[:slot_id])
  end

end
