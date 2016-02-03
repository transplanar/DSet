class SlotController < ApplicationController
  def show
  end

  def new
  end

  def create
  end

  def update
    @slot = Slot.find(params[:slot_id])
    @slot.update_attribute(:queries, params[:search])
  end

  def edit
    @slot = Slot.find(params[:slot_id])
  end

end
