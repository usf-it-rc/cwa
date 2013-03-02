class CwaAllocationsController < ApplicationController
  unloadable

  def index
    @user = CwaIpaUser.new

    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?

    @project = Project.find(Redmine::Cwa.project_id)
    @allocations = CwaAllocation.all :conditions => { :user_id => User.current.id }

    respond_to do |format|
      format.html
    end
  end

  def form
    @user = CwaIpaUser.new

    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?

    @project = Project.find(Redmine::Cwa.project_id)

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
    @user = CwaIpaUser.new

    (redirect_to :controller => 'cwa_default', :action => 'not_activated' and return) if !@user.provisioned?

    @allocations = CwaAllocation.all
    @project = Project.find(Redmine::Cwa.project_id)

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

    if params['cwa_allocation'] != nil
      params['cwa_allocation']['time_approved'] = Time.now if params['cwa_allocation']['approved'] == true
    end
    
    logger.debug "CwaAllocationController::update => " + params['cwa_allocation'].to_s
    allocation = CwaAllocation.find_by_id(params[:allocation_id]).update_attributes(params['cwa_allocation'])
    
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
