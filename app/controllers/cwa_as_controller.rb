class CwaAsController < ApplicationController
  unloadable

  def index
    @cwa_as = CwaAs.new
    @project = Project.find(@cwa_as.project_id)

    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end

    begin
      u = @cwa_as.ipa_exists(User.current.login.downcase)
    rescue Exception => e
      flash[:error] = e.message
    end

    if flash[:notice] != nil
      s = flash[:notice]
    end

    if u
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

  def user_shell
    @cwa_as = CwaAs.new
    @project = Project.find(@cwa_as.project_id)

    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => :no_auth
      return
    end
    if params[:loginshell]
      s = @cwa_as.shells.invert
      logger.debug s.to_s
      p = params[:loginshell]
      login_shell = s[p.to_i]
      logger.debug "Setting user shell to #{login_shell} from param #{p}"
    else
      redirect_to :action => :user_info
      return
    end

    begin
      @cwa_as.set_loginshell(login_shell)
    rescue
      flash[:error] = "There was a problem saving your options!"
    else
      flash[:notice] = "Options saved!"
    end

    redirect_to :action => :user_info
  end

  def user_info
    @cwa_as = CwaAs.new
    @project = Project.find(@cwa_as.project_id)

    respond_to do |format|
      format.html
    end
  end
 
  def no_auth
    @cwa_as = CwaAs.new
    respond_to do |format|
      format.html
    end
  end

  def success
  end

  # Create user by calling the private _provision method, handling errors
  # and returning to the index
  def create
    @cwa_as = CwaAs.new
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end

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

    begin
      _provision(User.current.login.downcase ,params[:netid_password], "user_add")
    rescue Exception => e
      flash[:error] = "Registration failed: " + e.message
    else
      logger.debug "Account #{User.current.login.downcase} provisioned in FreeIPA"
      flash[:notice] = 'You are now successfully registered!'
    end
    redirect_to :action => :index
  end

  def failure
    flash[:error] = 'Account registered'
    redirect_to :action => 'index'
  end

  def delete
    @cwa_as = CwaAs.new
    
    # some sanity checks
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end
    if (User.current.login.downcase == "admin")
      flash[:error] = "You cannot delete the admin user!"
      redirect_to :action => :index
      return
    end

    # Try the delete and catch errors
    begin
      _provision(User.current.login.downcase, nil, "user_del")
    rescue Exception => e
      logger.debug "Account #{User.current.login.downcase} failed to be de-provisioned in FreeIPA: " + e.message
      flash[:error] = "Deactivation failed: " + e.message
    else
      logger.debug "Account #{User.current.login.downcase} de-provisioned in FreeIPA"
      flash[:notice] = 'Your account has been deactivated!'
    end
    redirect_to :action => 'index'
  end

  private
    # Provision the account in the IPA server
    def _provision(user, password, action)
      @cwa_as = CwaAs.new

      user = _query_validate user, password, action == "user_del"
      logger.debug "_provision(): _query_validate() => " + user.to_s

      if (user == nil)
        raise 'This user was not found in the NetID system'
      elsif (user[:password] != "valid")
        raise 'You entered an incorrect password'
      end

      logger.debug "provision(): " + user.to_s

      json_string = <<EOF
{
  "method": "#{action}",
  "params": [
    [],
    {
      "uid":"#{user[:netid]}",
      "uidnumber":#{user[:namsid]},
      "givenname":"#{user[:givenname]}",
      "sn":"#{user[:sn]}",
      "homedirectory":"/home/#{user[:netid].each_char.first.downcase}/#{user[:netid].downcase}",
      "userpassword":"#{password}"
    }
  ]
}
EOF

      begin
        json_return = @cwa_as.json_helper(json_string)
      rescue Exception => e
        raise e.message
      end

      # TODO: parse out the details and return appropriate messages 
      if json_return['error'] != nil
        raise json_return['error']['message']
      end
    end

    # TODO: CAS Auth user and get some attributes
    def _query_validate(user, password, bypass)
      field_id = 0
      namsid = -100000

      if !bypass
        valid = _cas_verify_login(user, password, Setting.plugin_redmine_omniauth_cas['cas_url'])

        if !valid
          logger.debug "_query_validate(): bad credentials/configuration passed to cas"
          return { :password => "wrong" } 
        end
      end

      User.current.available_custom_fields.each do |field|
        if field.name == "namsid"
          field_id = field.id
          break
        end
      end

      User.current.custom_values.each do |field|
        if field.custom_field_id == field_id
          namsid = field.value
        end
      end

      h = { 
        :netid => user, :password => "valid", :namsid => namsid,
        :givenname => User.current.firstname, :sn => User.current.lastname 
      }

      logger.debug h.to_s

      h
    end

    def _cas_verify_login(user, password, url)
      c = Curl::Easy.http_get(url) do |curl|
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.verbose = false
        curl.enable_cookies = true
        curl.cookiefile = "/tmp/blah"
        curl.cookiejar = "/tmp/blah"
      end

      uri = URI.new

      uri.query_values = {
        :username => user,
        :password => password,
      }

      c.http_post(url, uri.query)
      c.response_code == 200 ? true : false
   end
end
