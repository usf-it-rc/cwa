class CwaAs < ActiveRecord::Base
  #attr_accessible :tos, :saa, :delete_saa
  def saa
    Setting.plugin_cwa_as[:saa]
  end
  def tos 
    Setting.plugin_cwa_as[:tos]
  end
  def pwd_agreement
    Setting.plugin_cwa_as[:pwd_agreement]
  end
  def ipa_server
    Setting.plugin_cwa_as[:ipa_server]
  end
  def ipa_account
    Setting.plugin_cwa_as[:ipa_account]
  end
  def ipa_password
    Setting.plugin_cwa_as[:ipa_password]
  end
  def delete_saa 
    Setting.plugin_cwa_as[:delete_saa]
  end
  def project_id
    Setting.plugin_cwa_as[:project_id]
  end
  def shells
     { "/bin/sh" => 0, "/bin/bash" => 1, "/bin/ash" => 2, "/bin/zsh" => 3,  "/bin/csh" => 4, "/bin/tcsh" => 5 }
  end
  def loginshell
     ipa_query(User.current.login.downcase)['result']['loginshell'].to_a.join ','
  end
  def set_loginshell(shell)
    user_set(User.current.login.downcase, { :loginshell => shell })
  end
  def givenname
    ipa_query(User.current.login.downcase)['result']['givenname'].to_a.join ','
  end
  def sn
    ipa_query(User.current.login.downcase)['result']['sn'].to_a.join ','
  end
  def uid
    ipa_query(User.current.login.downcase)['result']['uid'].to_a.join ','
  end
  def homedirectory
    ipa_query(User.current.login.downcase)['result']['homedirectory'].to_a.join ','
  end

  def ipa_query(user)
    if @ipa_user == nil
      json_query = <<EOF
{ "method": "user_show", 
  "params":[
   [],
   { "uid":"#{user}" }
   ] 
}
EOF
      begin
        r = json_helper(json_query)
      rescue Exception => e
        raise e.message
      else
        @ipa_user = r['result']
      end
    end
    logger.debug "ipa_query(): " + @ipa_user.to_s
    @ipa_user
  end

  def ipa_exists(user)
    begin
      r = ipa_query(user)       
    rescue Exception => e
      raise e.message 
    end 

    logger.debug "ipa_exists(): " + r.to_s
    if r != nil
      true
    else
      false
    end
  end

  def user_set(user,params)
    json_query = <<EOF
{ "method": "user_mod", 
  "params":[
   [],
    { 
     "uid":"#{user}",
EOF

    p_keys = params.keys
    last = p_keys.pop
    params.keys.each do |k|
      json_query += "     \"#{k.to_s}\":\"#{params[k]}\",\n" 
    end

    json_query += <<EOF 
     "#{last.to_s}":"#{params[last]}"
    }
   ] 
}
EOF
    json_helper(json_query)
  end

  def json_helper(json_string)
    url = "https://#{self.ipa_server}/ipa" 
    begin
      c = Curl::Easy.http_post(url + "/json", json_string) do |curl|
        curl.cacert = 'ca.crt'
        curl.http_auth_types = :basic
        curl.username = self.ipa_account
        curl.password = self.ipa_password
        curl.ssl_verify_host = false
        curl.ssl_verify_peer = false
        curl.verbose = false
        curl.headers['referer'] = url
        curl.headers['Accept'] = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
        curl.headers['Api-Version'] = '2.2'
      end 
    rescue
      raise 'Could not connect to FreeIPA!'
    end

    h = JSON.parse(c.body_str).to_hash
    logger.debug "json_helper(): " + h.to_s

    # If we get an error AND its not "user not found"
    if h['error'] != nil and h['error']['code'] != 4001
      logger.debug h['error'].to_s
      raise h['error']['message']
    else
      h
    end
  end
end
