class CwaAsController < ApplicationController
  unloadable

  def index
    @cwa_as = CwaAs.new
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end

    if (@cwa_as.ipa_exists(User.current.login.downcase))
      if (flash[:notice] != nil)
        redirect_to '/cwa_as/user_info', :flash => { :notice => flash[:notice] }
      else
        redirect_to :action => 'user_info'
      end
      return
    end

    respond_to do |format|
      format.html
    end
  end

  def user_shell
    @cwa_as = CwaAs.new
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end
    if params[:loginshell]
      s = @cwa_as.shells.invert
      logger.debug s.to_s
      p = params[:loginshell]
      login_shell = s[p.to_i]
      logger.debug "Setting user shell to #{login_shell} from param #{p}"
    else
      redirect_to :action => 'user_info'
      return
    end

    begin
      @cwa_as.set_loginshell(login_shell)
    rescue
      flash[:error] = "There was a problem saving your options!"
    else
      flash[:notice] = "Options saved!"
    end

    redirect_to :action => 'user_info'
  end

  def user_info
    @cwa_as = CwaAs.new
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

    begin
      _provision(User.current.login.downcase ,params[:netid_password])
    rescue Exception => e
      flash[:error] = "Registration failed: " + e.message
    else
      logger.debug "Account #{User.current.login.downcase} provisioned in FreeIPA"
      flash[:notice] = 'You are now successfully registered!'
    end
    redirect_to :action => 'index'
  end

  def failure
    flash[:error] = 'Account registered'
    redirect_to :action => 'index'
  end

  def delete
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end
  end

  private
    # Provision the account in the IPA server
    def _provision(user, password)
      @cwa_as = CwaAs.new
      user = _query_validate(user,password)

      if (user == nil)
        raise 'This user was not found in the NetID system'
      elsif (user[:password] != "valid")
        raise 'You entered an incorrect password'
      end

      json_string = <<EOF
{
  "method": "user_add",
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

      logger.debug json_string

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
    def _query_validate(user, password)
      return { :netid => user, :password => "valid", :namsid => 100, :givenname => "Admin", :sn => "istrator" }
    end
end
