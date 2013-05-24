class CwaAccountsignupController < ApplicationController
  unloadable

  def index
    Rails.logger.debug _user_not_anonymous.to_s

    _user_not_anonymous || return

    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable', :project_id => params[:project_id]
      return
    end

    # Are we an IPA user?
    @user = CwaIpaUser.new
    @project = Project.find_by_identifier(params[:project_id])

    Rails.logger.debug "CwaASC#index() " + @project.to_s

    n = flash[:notice] if flash[:notice] != nil
    e = flash[:error] if flash[:error] != nil

    if @user.provisioned?
      flash[:notice] = n.to_s if n != nil
      flash[:error] = e.to_s if e != nil

      redirect_to :action => :user_info
      return
    end

    respond_to do |format|
      format.html
    end
  end

  def set_shell
    _user_not_anonymous || return

    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end

    @user = CwaIpaUser.new

    if params[:loginshell]
      s = @user.available_shells.invert
      p = params[:loginshell]
      login_shell = s[p.to_i]
      logger.debug "Setting user shell to #{login_shell} from param #{p}"
    else
      redirect_to :action => :user_info, :project_id => params[:project_id]
      return
    end

    if @user.update :loginshell => login_shell
      CwaMailer.shell_change(@user).deliver
      flash[:notice] = "Options saved!"
    else
      flash[:error] = "There was a problem saving your options!"
    end

    redirect_to :action => :user_info, :project_id => params[:project_id]
  end

  def user_info
    _user_not_anonymous || return

    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end

    @user = CwaIpaUser.new
    @project = Project.find_by_identifier(params[:project_id])

    respond_to do |format|
      format.html
    end
  end
 
  # Create user by calling the private _provision method, handling errors
  # and returning to the index
  def create
    _user_not_anonymous || return

    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable', :project_id => params[:project_id]
      return
    end

    @project = Project.find_by_identifier(params[:project_id])
    @user = CwaIpaUser.new

    if !params[:saa] 
      flash[:error] = "Please indicate that you accept the system access agreement"
      redirect_to :action => :index, :project_id => params[:project_id]
      return
    end

    if !params[:tos]
      flash[:error] = "Please indicate that you accept the terms of service"
      redirect_to :action => :index, :project_id => params[:project_id]
      return
    end

    # TODO 
    # 1. Call REST to messaging service to notify about account creation
    # 2. Add user to research-computing project
    @user.passwd = params['netid_password']

    begin
      @user.create
    rescue Exception => e
      flash[:error] = "Registration failed: " + e.to_s
      redirect_to :action => :index, :project_id => params[:project_id]
      return
    end

    logger.info "Account #{@user.uid.first} provisioned in FreeIPA"

    # Add them to the project... allows notifications
    member = Member.create(:user => User.current, :roles => [Role.find_by_name("Watcher")])
    logger.debug "cwa_accountsignup_controller::create() " + member.to_s
    @project.members << member
    @project.save

    CwaMailer.activation(@user).deliver

    flash[:notice] = 'You are now successfully registered!'
    redirect_to :action => :index, :project_id => params[:project_id]
  end

  def delete
    # Re-direct to unavailable page
    if params[:project_id] != Redmine::Cwa.project_id 
      redirect_to :controller => 'cwa_default', :action => 'unavailable'
      return
    end
    _user_not_anonymous || return

    @user = CwaIpaUser.new
    @project = Project.find(Redmine::Cwa.project_id)

    # some sanity checks
    if (User.current.login.downcase == "admin")
      flash[:error] = "You cannot delete the admin user!"
      redirect_to :action => :user_info
      return
    end

    # Try the delete and catch errors
    if @user.destroy
      @user.refresh

      members = @project.members

      members.each do |member|
        member.destroy if member.user_id == User.current.id
      end
      @project.members = members
      logger.debug "Account #{User.current.login.downcase} de-provisioned in FreeIPA"
      CwaMailer.deactivation(@user).deliver
      flash[:notice] = 'Your account has been deactivated!'
    else
      logger.debug "Account #{User.current.login.downcase} failed to be de-provisioned in FreeIPA!"
      flash[:error] = "Deactivation failed!"
      redirect_to :action => :user_info
      return
    end
    redirect_to :action => :index, :project_id => params[:project_id]
  end

  private
  def _user_not_anonymous
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :controller => 'cwa_default', :action => 'authorization'
      return false
    end
    return true
  end
end
