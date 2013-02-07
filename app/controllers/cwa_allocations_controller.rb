class CwaAllocationsController < ApplicationController
  unloadable

  def index
    @project = Project.find(Setting.plugin_cwa[:project_id])
    @allocations = CwaAllocation.all( :conditions => { :user_id => User.current.id } )

    respond_to do |format|
      format.html
    end
  end

  def form
    @project = Project.find(Setting.plugin_cwa[:project_id])
    @allocation = CwaAllocation.new

    respond_to do |format|
      format.html
    end
  end

  def delete
    allocation = CwaAllocation.find_by_id(params[:allocation_id])
    if allocation.destroy
      flash[:notice] = "Allocation request deleted!"
      redirect_to "/cwa_allocations"
    else
      flash[:error] = "Couldn't delete allocation request! " + allocation.errors
      redirect_to "/cwa_allocations"
    end
  end
    
  def submit
    allocation = CwaAllocation.new do |a|
      a.summary = params[:cwa_allocation]['summary']
      a.proposal = params[:cwa_allocation]['proposal']
      a.time_in_hours = params[:cwa_allocation]['time_in_hours']
      a.time_submitted = Time.now
      a.user_id = User.current.id
      a.approved = false
      a.used_hours = 0
    end

    logger.debug "cwa_allocations::submit() " + allocation.summary

    if allocation.save
      flash[:notice] = "Allocation request saved!"
      redirect_to "/cwa_allocations"
    else
      flash[:error] = "Couldn't save allocation request! " + allocation.errors
      redirect_to "/cwa_allocations"
    end
  end
     

end
