class CwaAllocationsController < ApplicationController
  unloadable

  def index
    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end

    @user = CwaIpaUser.new

    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?

    @project = Project.find(params[:project_id])
    @allocations = CwaAllocation.all :conditions => { :user_id => User.current.id }

    respond_to do |format|
      format.html
    end
  end

  def form
    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end

    @user = CwaIpaUser.new

    @one_time_startup_count = CwaAllocation.find_all_by_allocation_type(1).count

    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?

    @project = Project.find(params[:project_id])

    if params[:cwa_allocation] != nil
      @allocation = CwaAllocation.new params[:cwa_allocation]
    else
      @allocation = CwaAllocation.new
    end

    respond_to do |format|
      format.html
    end
  end

  def admin
    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end

    @user = CwaIpaUser.new

    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?

    @allocations = CwaAllocation.all
    @project = Project.find(params[:project_id])

    if !User.current.admin?
      flash[:error] = "Only an administrator can do that!"
      redirect_to :action => :index
    end

    respond_to do |format|
      format.html
    end
  end

  def delete
    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end
    allocation = CwaAllocation.find_by_id(params[:allocation_id])

    CwaMailer.allocation_rejection(User.find_by_id(allocation.user_id), allocation).deliver if allocation.user_id != User.current.id

    if allocation.destroy
      flash[:notice] = "Allocation request deleted!"
      redirect_to :action => :index
    else
      flash[:error] = "Couldn't delete allocation request! " + allocation.errors.full_messages.to_sentence
      render :action => :index
    end
  end

  def update
    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end
    if !User.current.admin?
      flash[:error] = "Only an administrator can do that!"
      redirect_to :action => :index
    end

    allocation = CwaAllocation.find_by_id(params[:allocation_id])

    if params['cwa_allocation'] != nil
      if params['cwa_allocation']['approved'] == true
        params['cwa_allocation']['time_approved'] = Time.now
        CwaMailer.allocation_approval(User.find_by_id(allocation.user_id), allocation).deliver
      end
    end
    
    logger.debug "CwaAllocationController::update => " + params['cwa_allocation'].to_s
    allocation = allocation.update_attributes(params['cwa_allocation'])
    
    if allocation
      flash[:notice] = "Allocations updated!"
      redirect_to :action => :admin
    else       
      flash[:error] = "Couldn't save allocation request! " + allocation.errors.full_messages.to_sentence
      render :action => :admin
    end
  end
    
  def submit
    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end

    @project = Project.find(params[:project_id])

    if CwaAllocation.find(:all, :conditions => { :approved => true, :allocation_finished => nil }).count > 0
      flash[:error] = "You already have an active, unfinished allocation!"
      redirect_to :action => 'index'
      return
    end

    @allocation = CwaAllocation.new params[:cwa_allocation] do |a|
      a.time_submitted = Time.now
      a.user_id = User.current.id
      a.approved = false
      a.used_hours = 0
    end

    if @allocation.save
      CwaMailer.allocation_submit_confirmation(User.current, @allocation).deliver
      flash[:notice] = "Allocation request saved!"
      redirect_to :action => :index
    else
      flash[:error] = "Couldn't save allocation request! " + @allocation.errors.full_messages.to_sentence
      render :action => :form
    end
  end
end
