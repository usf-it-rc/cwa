class CwaAs < ActiveRecord::Base
  # This gets us all of our accessor methods for plugin settings
  # and ipa-based attributes
  def method_missing(name, *args, &blk)
    if args.empty? && blk.nil? && Setting.plugin_cwa_as.has_key?(name)
      Setting.plugin_cwa_as[name]
    elsif args.empty? && blk.nil? 
      ipa_record = ipa_query(User.current.login.downcase)['result'] 
      if ipa_record.has_key?(name.to_s)
        ipa_record[name.to_s].to_a.join
      else
        super
      end
    else
      super
    end
  end

  # List of allowed shells
  def shells
     { "/bin/sh" => 0, "/bin/bash" => 1, "/bin/ash" => 2, "/bin/zsh" => 3,  "/bin/csh" => 4, "/bin/tcsh" => 5 }
  end

  # Set user shell
  def set_loginshell(shell)
    user_set(User.current.login.downcase, { :loginshell => shell })
  end

  # Get wonderful attributes from IPA server
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
    @ipa_user
  end

  # Wrap around ipa_query to give a true/false for whether the user exists
  def ipa_exists(user)
    begin
      r = ipa_query(user)       
    rescue Exception => e
      raise e.message 
    end 
    r != nil ? true : false
  end

  # update user parameters in IPA
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

  # Do the JSON-RPC call for us
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
