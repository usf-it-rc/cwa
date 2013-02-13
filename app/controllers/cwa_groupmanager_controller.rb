class CwaGroupmanagerController < ApplicationController
  unloadable

  # Load the default view
  def index
    @project = Project.find(Redmine::Cwa.project_id)
    @groups = CwaGroups.new
    respond_to do |format|
      format.html
    end
  end

  def groups
    @project = Project.find(Redmine::Cwa.project_id)
    @gs = CwaGroups.new
    respond_to do |format|
      format.html
    end
  end

  def show
    @project = Project.find(Redmine::Cwa.project_id)
    @gs = CwaGroups.new
    respond_to do |format|
      format.html
    end
  end

  def create 
    @project = Project.find(Redmine::Cwa.project_id)
    respond_to do |format|
      format.html
    end
  end

  # Create group
  def create_group
    @project = Project.find(Redmine::Cwa.project_id)
    @groups = CwaGroups.new
    Rails.logger.debug "create_group() => " + @groups.that_i_manage.length.to_s
    if @groups.that_i_manage.length < 5
      if @groups.create({ :owner => User.current.login, :group_name => params[:group_name], :desc => params[:desc] })
        flash[:notice] = "Your group \"#{params[:group_name]}\" has been created!"
      else
        flash[:error] = "Could not create group \"#{params[:group_name]}\".  Name is already taken!"
        render :action => :create
        return
      end
    else
      flash[:error] = "You've reached the maximum 10 group limitation.  You can't have any more!"
    end
    redirect_to :action => :index
  end

  def delete_group
    @groups = CwaGroups.new
    if @groups.delete params[:group_name]
      flash[:notice] = "Group \"#{params[:group_name]}\" deleted!"
    else
      flash[:error] = "Unable to delete group \"#{params[:group_name]}\"!"
    end
    redirect_to :action => :index
  end

  # Add a user to a group
  def add
    @groups = CwaGroups.new

    if @groups.add_to_my_group(params[:user_name], params[:group_name])
      flash[:notice] = "\"#{params[:user_name]}\" has been added to \"#{params[:group_name]}\""
    else
      flash[:error] = "There was a problem adding \"#{params[:user_name]}\" to \"#{params[:group_name]}\".  The user probably does not exist."
    end
    redirect_to :action => :show, :group_name => params[:group_name]
  end

  # Delete a user from a group
  def delete
    @groups = CwaGroups.new

    if params[:user_name]
      if @groups.delete_from_my_group(params[:user_name], params[:group_name])
        flash[:notice] = "\"#{params[:user_name]}\" has been removed from \"#{params[:group_name]}\""
      else
        flash[:error] = "There was a problem removing \"#{params[:user_name]}\" from \"#{params[:group_name]}\""
      end
    else
      if @groups.delete_me_from_group params[:group_name]
        flash[:notice] = "You have been removed from group \"#{params[:group_name]}\""
      else
        flash[:error] = "There was a problem removing you from group \"#{params[:group_name]}\""
      end
    end
    redirect_to :action => :show, :group_name => params[:group_name]
  end

  def disband
    groups = CwaGroups.new

    if groups.delete(params[:group_name])
      flash[:notice] = "\"#{params[:group_name]}\" has been disbanded!"
    else
      flash[:error] = "Problem disbanding \"#{params[:group_name]}\""
    end
    redirect_to :action => :index
  end

  def delete_request
    groups = CwaGroups.new
    request = CwaGroupRequests.find_by_id(params[:request_id])
    group_name = groups.by_id(request.group_id)[:cn]

    if request.delete
      flash[:notice] = "Request to join \"#{group_name}\" removed."
    else
      flash[:error] = "There was a problem removing your request to join \"#{group_name}\""
    end
    redirect_to :action => :index
  end

  def allow_join
    groups = CwaGroups.new
    request = CwaGroupRequests.find_by_id(params[:request_id])
    group_name = groups.by_id(request.group_id)[:cn]
    user_name = User.find_by_id(request.user_id).login

    if groups.add_to_my_group(user_name, group_name)
      request.delete
      flash[:notice] = "User #{user_name} added to group #{group_name}!"
    else
      flash[:error] = "Problem adding #{user_name} to group #{group_name}!"
    end
    redirect_to :action => :index
  end
      
  # store request to join group
  def save_request
    if CwaGroupRequests.find(:first, :conditions => ["group_id = ? and user_id = ?", params[:gidnumber], User.current.id])
      flash[:error] = "You've already requested to join this group!"
    else
      req = CwaGroupRequests.create do |r|
        r.group_id = params[:gidnumber]
        r.user_id  = User.current.id
      end
 
      if req
        flash[:notice] = "Your request to join #{params[:group_name]} has been registered!"
      else
        flash[:error] = "There was a problem registering your request to join  #{params[:group_name]}!"
      end
    end
    redirect_to :action => :index
  end
end
