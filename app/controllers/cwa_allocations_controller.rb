class CwaAllocationsController < ApplicationController
  unloadable

  def index
    respond_to do |format|
      format.html
    end
  end

  def form
    respond_to do |format|
      format.html
    end
  end

  def admin
    if !User.current.admin?
      flash[:error] = "Only an administrator can do that!"
      redirect_to :action => :index
    end

    respond_to do |format|
      format.html
    end
  end

  def delete
    allocation = CwaAllocation.find_by_id(params[:allocation_id])
    if allocation.destroy
      flash[:notice] = "Allocation request deleted!"
      redirect_to :action => :index
    else
      flash[:error] = "Couldn't delete allocation request! " + allocation.errors.full_messages.to_sentence
      render :action => :index
    end
  end

  def update
    if !User.current.admin?
      flash[:error] = "Only an administrator can do that!"
      redirect_to :action => :index
    end

    if params[:cwa_allocation] != nil
      params[:cwa_allocation]['time_approved'] = Time.now if params[:cwa_allocation]['approved'] = true
    end
    
    allocation = CwaAllocation.update(params[:allocation_id], params[:cwa_allocation])
    
    if allocation
      flash[:notice] = "Allocations updated!"
      redirect_to :action => :admin
    else       
      flash[:error] = "Couldn't save allocation request! " + allocation.errors.full_messages.to_sentence
      render :action => :admin
    end
  end
    
  def submit
    allocation = CwaAllocation.new params[:cwa_allocation] do |a|
      a.time_submitted = Time.now
      a.user_id = User.current.id
      a.approved = false
      a.used_hours = 0
    end

    if allocation.save
      flash[:notice] = "Allocation request saved!"
      redirect_to :action => :index
    else
      flash[:error] = "Couldn't save allocation request! " + allocation.errors.full_messages.to_sentence
      render :action => :form
    end
  end
end
