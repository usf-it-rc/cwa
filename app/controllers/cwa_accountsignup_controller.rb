class CwaAccountsignupController < ApplicationController
  unloadable

  def index
    @user = CwaIpaUser.new
    @project = Project.find(Redmine::Cwa.project_id)

    _user_not_anonymous

    if flash[:notice] != nil
      s = flash[:notice]
    end

    if @user.provisioned?
      if s != nil
        flash[:notice] = s.to_s
      end
      redirect_to :action => :user_info
      return
    end

    respond_to do |format|
      format.html
    end
  end

  def set_shell
    @user = CwaIpaUser.new

    _user_not_anonymous

    if params[:loginshell]
      s = @user.available_shells.invert
      p = params[:loginshell]
      login_shell = s[p.to_i]
      logger.debug "Setting user shell to #{login_shell} from param #{p}"
    else
      redirect_to :action => :user_info
      return
    end

    if @user.update :loginshell => login_shell
      flash[:notice] = "Options saved!"
    else
      flash[:error] = "There was a problem saving your options!"
    end

    redirect_to :action => :user_info
  end

  def user_info
    @user = CwaIpaUser.new
    @project = Project.find(Redmine::Cwa.project_id)

    _user_not_anonymous

    respond_to do |format|
      format.html
    end
  end
 
  # Create user by calling the private _provision method, handling errors
  # and returning to the index
  def create
    _user_not_anonymous
    @user = CwaIpaUser.new
    @project = Project.find(Redmine::Cwa.project_id)

    if !params[:saa] 
      flash[:error] = "Please indicate that you accept the system access agreement"
      redirect_to :action => :index
      return
    end

    if !params[:tos]
      flash[:error] = "Please indicate that you accept the terms of service"
      redirect_to :action => :index
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
    else
      logger.info "Account #{@user.uid.first} provisioned in FreeIPA"

      # Add them to the project... allows notifications
      @project.members << Member.new(:user => User.current, :roles => [Role.find_by_name("Watcher")])

      flash[:notice] = 'You are now successfully registered!'
    end
    redirect_to :action => :index
  end

  def delete
    _user_not_anonymous

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
      flash[:notice] = 'Your account has been deactivated!'
    else
      logger.debug "Account #{User.current.login.downcase} failed to be de-provisioned in FreeIPA!"
      flash[:error] = "Deactivation failed!"
      redirect_to :action => :user_info
      return
    end
    redirect_to :action => :index
  end

  private
  def _user_not_anonymous
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end
  end
end
