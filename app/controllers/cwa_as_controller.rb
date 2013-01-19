class CwaAsController < ApplicationController
  unloadable

  def index
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
    begin
      _provision(User.current.login ,params[:password])
    rescue Exception => e
      flash[:error] = e.message
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
      url = "https://#{@plugin.ipa_server}/ipa" 
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
      "userpassword":"#{password}",
    }
  ]
}
EOF

      # Create account by pushing JSON request to server
      begin
        c = Curl::Easy.http_post(url + "/json", json_string) do |curl|
          curl.cacert = 'ca.crt'
          curl.http_auth_types = :basic
          curl.username = @plugin.ipa_account
          curl.password = @plugin.ipa_password
          curl.headers['referer'] = url
          curl.headers['Accept'] = 'application/json'
          curl.headers['Content-Type'] = 'application/json'
          curl.headers['Api-Version'] = '2.2'
        end 
      rescue
        raise 'Could not connect to FreeIPA server to provision account!'
      end

      json_return = JSON.parse(c.body_str).to_hash
      # TODO: parse out the details and return appropriate messages 

    end

    # TODO: CAS Auth user and get some attributes
    def _query_validate(user, password)
      return { :netid => user, :password => "valid", :namsid => 100, :givenname => "Admin", :sn => "istrator" }
    end

end
