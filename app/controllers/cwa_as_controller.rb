class CwaAsController < ApplicationController
  unloadable

  def index
    @plugin = CwaAs.new
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end

#    if (_ipa_exists(User.current.login.downcase))
#      redirect_to :action => 'user_info'
#      return
#    end

    respond_to do |format|
      format.html
    end
  end

  def user_info
    @plugin =CwaAs.new
    respond_to do |format|
      format.html
    end
  end
 
  def no_auth
    @plugin = CwaAs.new
    respond_to do |format|
      format.html
    end
  end

  def success
  end

  # Create user by calling the private _provision method, handling errors
  # and returning to the index
  def create
    @plugin = CwaAs.new
    if (User.current.lastname.downcase == "anonymous")
      redirect_to :action => 'no_auth'
      return
    end

    begin
      _provision(User.current.login.downcase ,params[:netid_password])
    rescue Exception => e
      flash[:error] = "Registration failed: " + e.message
    else 
      flash[:notice] = 'You are now successfully registered!'
    end
    redirect_to :action => 'index'
  end

  def failure
    flash[:error] = 'Account registered'
    redirect_to :action => 'index'
  end

  def delete
  end

  private
    # Provision the account in the IPA server
    def _provision(user, password)
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
        json_return = _json_helper(json_string)
      rescue
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

    def _ipa_exists(user)
      logger.debug _ipa_query(user) 
      return true
    end

    def _ipa_query(user)
      json_query = <<EOF
{ "method": "user_find", "params":[[""],{}],"uid":"#{user}"}
EOF
      _json_helper(json_query)
    end

    def _json_helper(json_string)
      url = "https://#{@plugin.ipa_server}/ipa" 
      begin
        c = Curl::Easy.http_post(url + "/json", json_string) do |curl|
          curl.cacert = 'ca.crt'
          curl.http_auth_types = :basic
          curl.username = @plugin.ipa_account
          curl.password = @plugin.ipa_password
          curl.ssl_verify_host = false
          curl.ssl_verify_peer = false
          curl.verbose = true
          curl.headers['referer'] = url
          curl.headers['Accept'] = 'application/json'
          curl.headers['Content-Type'] = 'application/json'
          curl.headers['Api-Version'] = '2.2'
        end 
      rescue
        raise 'Could not connect to FreeIPA!'
      end

      JSON.parse(c.body_str).to_hash
    end
      

end
